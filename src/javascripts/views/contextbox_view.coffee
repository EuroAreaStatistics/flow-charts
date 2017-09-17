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
    @subscribeEvent 'contextbox:explainMagnet', @explainMagnet
    @subscribeEvent 'contextbox:hide', @handleHideEvent

  getTemplateFunction: ->
    null

  explainMagnet: (options) ->
    {elementModel, x, y, parent} = options
    {type, unit} = elementModel.dataType

    return unless parent.has(@$el).length

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

    @showBox { html: text, x, y }
    return

  showBox: (options) ->
    { html, x, y } = options

    @$el.html(html).addClass 'visible'
    @$el.css marginTop: -0.75 * @$el.height()
    return

  handleHideEvent: ->
    @$el.removeClass 'visible'
    return

  # I18n shortcuts

  entityName: (id) =>
    @t 'entityNames', id

module.exports = ContextboxView
