'use strict'
_ = require 'lodash'
formatNumber = require 'lib/format_number'
View = require 'views/view'
template = require 'templates/legend.hamlc'

# Constants
OPENED_CLASS = 'legend--opened'
CLOSED_CLASS = 'legend--closed'

class LegendView extends View

  # Property declarations
  # ---------------------
  #
  # model: Keyframe

  tagName: 'section'
  templateName: 'legend'

  className: 'legend'

  autoRender: true

  events:
    'click .legend__toggle': 'toggleButtonClicked'
    'click .legend__close': 'closeButtonClicked'

  initialize: (options) ->
    super

    # Overlay mode
    @$el.addClass(
      if options.overlay then 'legend--overlay' else 'legend--sidebar'
    )

    return

  getTemplateFunction: ->
    template

  toggleButtonClicked: (event) ->
    event.preventDefault()
    if @$el.hasClass(OPENED_CLASS)
      @close()
    else
      @open()

  closeButtonClicked: (event) ->
    event.preventDefault()
    @close()
    return

  close: ->
    @$('.legend__toggle').text @t('legend', 'toggle_open')
    @$el.addClass(CLOSED_CLASS).removeClass(OPENED_CLASS)
    return

  open: ->
    @$('.legend__toggle').text @t('legend', 'toggle_close')
    @$el.addClass(OPENED_CLASS).removeClass(CLOSED_CLASS)
    return

  toggle: ->
    if @$el.hasClass(OPENED_CLASS)
      @close()
    else
      @open()
    return

  render: ->
    super if @model
    @close()
    this

  getTemplateData: ->
    data = super

    {type, unit} = data.dataType

    typeName = @t 'dataType', type
    unitName = @t 'units', unit, 'full'
    data.typeName = typeName
    data.unitName = unitName

    data.dataSource = @getDataSource()
    data.indicators = @getIndicators()
    data.groupedIndicators = _.groupBy data.indicators, 'representation'

    colors = @model.get('configuration').color 'magnets', type
    data.magnetOutgoingColor = colors.outgoing
    data.magnetIncomingColor = colors.incoming

    templateData = {
      date: data.date
      type: typeName
      unit: unitName
    }
    data.magnetDescription = @template(
      ['data', type, 'magnet'], templateData
    )
    data.relationDescription = @template(
      ['data', type, 'flow'], templateData
    )

    data

  getDataSource: ->
    type = @model.get('dataType').type
    @t 'sources', 'data', type

  getIndicators: ->
    configuration = @model.get 'configuration'
    indicators = _.map @model.get('indicatorTypes'), (indicatorType) =>
      {type, unit} = indicatorType
      {name: sourceName, url: sourceURL} = @t 'sources', 'indicator', type
      maxValue = @model.getIndicatorMaxValue indicatorType
      maxValue = @template(
        ['units', unit, 'value']
        number: formatNumber(configuration, maxValue, null, null, true)
      )
      {
        type: @t('indicators', type, 'short')
        typeFull: @t('indicators', type, 'full')
        unit:  @t('units', unit, 'short')
        unitFull:  @t('units', unit, 'full')
        representation: indicatorType.representation
        maxValue
        sourceName
        sourceURL
      }

module.exports = LegendView
