'use strict'
_ = require 'lodash'
$ = require 'jquery'
Raphael = require 'raphael'
DisplayObject = require 'display_objects/display_object'
IndicatorVisualization = require 'display_objects/indicator_visualization'
formatNumber = require 'lib/format_number'
scale = require 'lib/scale'

class Indicator extends DisplayObject

  ANIMATION_DURATION = 1000

  # Property Declarations
  # ---------------------
  #
  # element: Element
  # model: IndicatorModel
  # configuration: Object
  #
  # align: String
  #   Alignment of the text
  #
  # el: jQuery
  #   The main container element
  #
  # valueContainer: jQuery
  # unit: jQuery
  # value: jQuery
  #
  # visualizationContainer: jQuery
  # visualizationPaper: Raphael.Paper
  # visualization: IndicatorVisualization
  #
  # tendencyArrowContainer: jQuery
  # tendencyArrow: Raphael.Set
  # tendencyArrowPaper: Raphael.Paper
  # tendencyPercent: jQuery
  #
  # labels: jQuery
  # shortLabel: jQuery
  # fullLabelAndDescription: jQuery
  # fullLabel: jQuery
  # descriptionLabel: jQuery
  #
  # Drawing variables which are passed in:
  #
  # paper: Raphael.Paper
  # side: String
  #   Placement in the chart (top, right, bottom or left)

  DRAW_OPTIONS: 'paper side'.split(' ')

  constructor: (@element, @model, @configuration) ->
    super

    @initStates
      # path states
      #   normal: short label
      #   highlight: full label, detailed description
      states: ['normal', 'highlight']
      initialState: 'normal'

  # Updating
  # --------

  update: (@model, @configuration) ->

  # Drawing
  # -------

  draw: (options) ->
    @saveDrawOptions options

    @smallestSide = Math.min @paper.width, @paper.height

    @drawElement() unless @drawn

    drawVisualization = options.drawVisualization ? true
    @drawVisualization() if drawVisualization

    if @paper.width > 300
      @drawValue()
      @drawTendency()
      @drawLabels()

    # Append the topmost container to the DOM
    unless @drawn
      options.$container.append @el

    @drawn = true
    return

  # Creates the HTML container for several labels
  # ---------------------------------------------

  drawElement: ->
    align = if @side is 'left' then 'left' else 'right'
    fontSize = scale 'indicatorFontSize', @smallestSide
    @el = $('<div>')
      .addClass("indicator side-#{align}")
      .css('font-size', "#{fontSize}px")
    @addChild @el

    # Also create a container for all labels and stuff
    paddingTop = scale 'indicatorTopPadding', @smallestSide
    @labels = $('<div>')
      .addClass('indicator-labels')
      .css('padding-top', "#{paddingTop}px")
      .hover(
        _.bind(@transitionTo, this, 'highlight'),
        _.bind(@transitionTo, this, 'normal')
      )
      .appendTo(@el)

    return

  # Draws a visualization depending on the type
  # -------------------------------------------

  drawVisualization: ->
    # Create a new paper, append it to the element
    @visualizationContainer or= $('<div>')
      .addClass('indicator-visualization')

    # Insert before or after label depending on the side
    if @side is 'left'
      @labels.after @visualizationContainer
    else # top, right, bottom
      @labels.before @visualizationContainer

    width = scale 'visualizationSize', @smallestSide
    height = width

    @visualizationPaper or= Raphael(
      @visualizationContainer.get(0), width, height
    )

    @visualization or= new IndicatorVisualization this
    @visualization.update @model, @configuration
    @visualization.draw {
      paper: @visualizationPaper
      x: 0
      y: 0
      width
      height
    }

    return

  # Creates the value labels
  # ------------------------

  drawValue: ->
    if @model.missing is false
      number = formatNumber(
        @configuration, @model.value, null, null, true
      )
      value = @template ['units', @model.unit, 'value_html'], {number}
    else
      value = @t 'not_available'

    if @valueContainer
      # Fill existing
      @valueContainer.html value
    else
      # Create element from scratch
      @valueContainer = $('<div>')
        .addClass('indicator-value-and-unit')
        .html(value)
        .appendTo(@labels)

    return

  # Creates the tendency arrow
  # --------------------------

  TENDENCY_ARROW_WIDTH = 12
  TENDENCY_ARROW_HEIGHT = 12

  drawTendency: ->
    @drawTendencyArrow()
    @drawTendencyPercent()

  drawTendencyArrow: ->
    # Ensure container element and paper exist
    unless @tendencyArrowContainer
      @createTendencyArrowContainer()

    # Remove existing arrow if there is no tendency data
    unless @model.tendency?
      # Hide the container
      if @tendencyArrowContainer
        @tendencyArrowContainer.hide()
      # Remove the SVG paths
      if @tendencyArrow
        @tendencyArrow.remove()
        delete @tendencyArrow
      return

    # Ensure the container is visible
    @tendencyArrowContainer.show()

    rotation = @getTendencyArrowRotation @model.tendency
    rotationCenterX = TENDENCY_ARROW_WIDTH / 2
    rotationCenterY = TENDENCY_ARROW_HEIGHT / 2
    transform = "r#{rotation},#{rotationCenterX},#{rotationCenterY}"

    # Animate existing arrow
    if @tendencyArrow
      @tendencyArrow.animate {transform}, ANIMATION_DURATION, 'linear'
      return

    # Create new arrow
    @createTendencyArrow transform

    return

  # Sets tendencyArrowContainer and tendencyArrowPaper
  createTendencyArrowContainer: ->
    @tendencyArrowContainer = $('<div>')
      .addClass('indicator-tendency-arrow')
      .appendTo(@labels)

    @tendencyArrowPaper = Raphael(
      @tendencyArrowContainer.get(0),
      TENDENCY_ARROW_WIDTH,
      TENDENCY_ARROW_HEIGHT
    )

    return

  getTendencyArrowRotation: (tendency) ->
    switch tendency
      when 2 # heavily increasing
        -90
      when 1 # increasing
        -45
      #when 0 # steady
      # no rotation
      when -1 # decreasing
        45
      when -2 # heavily decreasing
        90

  # Sets tendencyArrow
  createTendencyArrow: (transform) ->
    paper = @tendencyArrowPaper
    strokeAttributes =
      stroke: @configuration.color('tendencyArrow')
      'stroke-width': 1.5
    width = TENDENCY_ARROW_WIDTH
    height = TENDENCY_ARROW_HEIGHT

    linePath = Raphael.format "M{0},{1} L{2},{3}",
      0, height / 2,
      width, height / 2
    line = paper.path(linePath).attr(strokeAttributes)

    tipPath = Raphael.format "M{0},{1} L{2},{3} L{4},{5}",
      width * 0.55, height * 0.1,
      width * 0.95, height / 2,
      width * 0.55, height * 0.9

    tip = paper.path(tipPath).attr(strokeAttributes)

    set = @paper.set()
    set.push tip, line
    # Finally rotate the paths
    set.transform transform

    @tendencyArrow = set

    return

  drawTendencyPercent: ->
    percent = @model.tendencyPercent

    # Create the element and add it to the DOM
    unless @tendencyPercent
      @tendencyPercent = $('<div>')
        .addClass('indicator-tendency-percent')
        .appendTo(@labels)

    # Empty the element if there is no data
    unless percent?
      @tendencyPercent.html ''
      return

    # Build string “(+ 12.34 %)”
    narrowSpace = '<span class="narrow-space">&nbsp;</span>'
    sign = if percent >= 0 then "+#{narrowSpace}" else ''
    isAbsolute = @model.representation is 'absolute'
    unit = if isAbsolute then "#{narrowSpace}%" else ''
    percent *= 100 if isAbsolute
    percent = formatNumber(
      @configuration, percent, null, null, true
    )
    html = "(#{sign}#{percent}#{unit})"

    # Fill element
    @tendencyPercent.html html

    return

  # Creates the description labels
  # ------------------------------

  drawLabels: ->
    {type, unit} = @model

    # Get label strings

    shortLabelText = @t 'indicators', type, 'short'
    fullLabelText = @t 'indicators', type, 'full'
    descriptionText = @template(
      ['value_in_unit'],
      unit: @t('units', unit, 'full')
    )

    # Create/update the elements
    texts = {shortLabelText, fullLabelText, descriptionText}
    if @shortLabel
      @fillLabels texts
    else
      @createLabels texts

    return

  createLabels: (texts) ->
    @shortLabel = $('<div>')
      .addClass('indicator-short-label')
      .text(texts.shortLabelText)
      .appendTo(@labels)

    @fullLabelAndDescription = $('<div>')
      .addClass('indicator-full-label-and-description')

    @fullLabel = $('<div>')
      .addClass('indicator-full-label')
      .text(texts.fullLabelText)
      .appendTo(@fullLabelAndDescription)

    if texts.descriptionText
      @descriptionLabel = $('<div>')
        .addClass('indicator-description')
        .text(texts.descriptionText)
        .appendTo(@fullLabelAndDescription)

    @fullLabelAndDescription.appendTo @labels
    return

  fillLabels: (texts) ->
    @shortLabel.text texts.shortLabelText
    @fullLabel.text texts.fullLabelText
    if texts.descriptionText
      @descriptionLabel.text(texts.descriptionText).show()
    else
      @descriptionLabel.hide()
    return

  # State change handlers
  # ---------------------

  enterNormalState: ->
    return unless @el
    @fullLabelAndDescription.stop(true, true).slideUp 'fast', =>
      @el.removeClass 'open'
    return

  enterHighlightState: ->
    return unless @el
    @fullLabelAndDescription.stop(true, true).slideDown 'fast'
    @el.addClass 'open'
    return

module.exports = Indicator
