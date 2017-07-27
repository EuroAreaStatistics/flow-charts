'use strict'
_ = require 'lodash'
View = require 'views/view'
utils = require 'lib/utils'
formatNumber = require 'lib/format_number'

class ContextboxView extends View

  # Property declarations
  # ---------------------
  #
  # model: Presentation

  className: 'contextbox'
  autoRender: true

  initialize: ->
    super
    @subscribeEvent 'contextbox:explainRelation', @explainRelation
    @subscribeEvent 'contextbox:explainMagnet', @explainMagnet
    @subscribeEvent 'contextbox:hide', @handleHideEvent

  getTemplateFunction: ->
    null

  explainRelation: (options) ->
    {from, to, value} = options
    {type, unit} = from.model.dataType

    configuration = @model.get 'configuration'

    percentFrom = formatNumber(
      configuration,
      (100 / from.model.sumOut * value).toFixed(1),
      null, null, true
    ) + '%'
    percentTo = formatNumber(
      configuration,
      (100 / to.model.sumIn * value).toFixed(1),
      null, null, true
    ) + '%'

    formattedValue = formatNumber(
      configuration, value, null, null, true
    )

    templateData =
      from: @t('entityNames', from.id)
      to: @t('entityNames', to.id)
      dataType: @t('dataType', type)
      percentFrom: percentFrom
      percentTo: percentTo
      value: formattedValue
      unit: @t('units', unit, 'full')
      date: from.model.date

    text = '<p>'
    text += @template ['contextbox', 'relation', type], templateData
    if value >= 0
      text += @template ['contextbox', 'relationPercentage', type], templateData
    text += '</p>'

    # Missing relations
    if options.missingRelations
      text += '<p>'
      text += @t 'contextbox', 'relation', 'missing', 'intro'
      text += '</p>'
      text += '<ul>'
      for fromCountry, toCountries of options.missingRelations
        templateData =
          source: @entityName(fromCountry)
          targets: @joinList(_.map(toCountries, @entityName))
        text += '<li>'
        text += @template(
          ['contextbox', 'relation', 'missing', 'entry']
          templateData
        )
        text += '</li>'
      text += '</ul>'

    @showBox text
    return

  explainMagnet: (elementModel) ->
    {type, unit} = elementModel.dataType

    configuration = @model.get 'configuration'

    templateData =
      name: @t('entityNames', elementModel.id)
      sumIn: formatNumber(
        configuration, elementModel.sumIn, null, null, true
      )
      sumOut: formatNumber(
        configuration, elementModel.sumOut, null, null, true
      )
      type: @t('dataType', type)
      unit: @t('units', unit, 'full')
      date: elementModel.date

    # Display missing relations as N/A instead of 0 units
    if elementModel.noIncoming.length > 0
      templateData.sumIn = @t 'not_available'
    if elementModel.noOutgoing.length > 0
      templateData.sumOut = @t 'not_available'

    text = '<p>'
    text += @template ['contextbox', 'magnet', type], templateData
    text += '</p>'

    # Missing incoming relations
    if elementModel.noIncoming.length > 0
      noIncoming = _.map elementModel.noIncoming, @entityName
      text += '<p>'
      text += @template(
        ['contextbox', 'magnet_missing', 'incoming', type]
        list: @joinList(noIncoming)
      )
      text += '</p>'

    # Missing outgoing relations
    if elementModel.noOutgoing.length > 0
      noOutgoing = _.map elementModel.noOutgoing, @entityName
      text += '<p>'
      text += @template(
        ['contextbox', 'magnet_missing', 'outgoing', type]
        list: @joinList(noOutgoing)
      )
      text += '</p>'

    @showBox text
    return

  showBox: (html) ->
    @$el.html(html).addClass 'visible'
    return

  handleHideEvent: ->
    @$el.removeClass 'visible'
    return

  # I18n shortcuts

  entityName: (id) =>
    @t 'entityNames', id

module.exports = ContextboxView
