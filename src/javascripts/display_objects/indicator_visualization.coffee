'use strict'
_ = require 'lodash'
$ = require 'jquery'
Raphael = require 'raphael'
DisplayObject = require 'display_objects/display_object'

# Shortcuts
# ---------

{sin, cos, PI} = Math

class IndicatorVisualization extends DisplayObject

  ANIMATION_DURATION = 1000

  # Property declarations
  # ---------------------
  #
  # model: IndicatorModel
  #
  # circle: Raphael.Element
  # percentCircle: Raphael.Element
  # percentArc: Raphael.Element
  # percentOverlay: Raphael.Element
  #
  # Drawing variables which are passed in:
  #
  # paper: Raphael.Paper
  # x: Number
  # y: Number
  # width: Number
  # height: Number

  DRAW_OPTIONS: 'paper x y width height'.split(' ')

  # Updating
  # --------

  update: (@model, @configuration) ->

  # Drawing
  # -------

  draw: (options) ->
    @saveDrawOptions options

    if @model.representation is 'proportional'
      @drawPercent()
    else
      @drawCircle()

    @addMouseHandlers()

    @drawn = true
    return

  # Draws the circle visualization (absolute)
  # -----------------------------------------

  drawCircle: ->
    {paper, x, y, width, height, model} = this

    x += width / 2
    y += height / 2
    max = width / 2
    min = max * 0.25
    radius = model.scale * (max - min) + min
    radius = min if radius < min
    colorName = if model.value < 0
      'indicatorCircleNegative'
    else
      'indicatorCirclePositive'
    fillColor = @configuration.color colorName

    if @circle
      @circle
        .stop()
        .animate({fill: fillColor, r: radius}, ANIMATION_DURATION, 'linear')
    else
      @circle = paper.circle(x, y, radius)
        .attr(fill: fillColor, 'stroke-opacity': 0)
      @addChild @circle

    return

  # Draws the percent visualization (proportional)
  # ----------------------------------------------

  drawPercent: ->
    {paper, x, y, width, height, model} = this

    x +=  width / 2
    y += height / 2
    radius = width / 2

    # Circle in background
    unless @percentCircle
      @percentCircle = paper.circle(x, y, radius).attr(
        fill: @configuration.color('indicatorCirclePositive')
        'stroke-opacity': 0
      )
      @addChild @percentCircle

    # Percent arc
    ratio = model.value / 100
    colorName = if ratio < 0
      'indicatorCircleNegative'
    else
        'indicatorPercentArc'
    fillColor = @configuration.color colorName
    arcAttributes = fill: fillColor, 'stroke-opacity': 0

    # TODO test different ratios (<0, >1…)
    if Math.abs(ratio) >= 1
      if @arc
        arcAttributes.r = radius
        @percentArc
          .stop()
          .animate(arcAttributes, ANIMATION_DURATION, 'linear')
      else
        @percentArc = paper.circle(x, y, radius).attr(arcAttributes)
        @addChild @percentArc
    else
      degrees = 360 * ratio
      radians = (PI * 2 * ratio) - PI / 2
      pathString = """
        M {0}, {1}
        v {2}
        A {3}, {3} {4} {5} {6} {7}, {8}
        z
      """
      pathString = Raphael.format(
        pathString,
        x, y,
        0 - radius,
        radius,
        degrees,
        if Math.abs(degrees) >= 180 then 1 else 0,
        if ratio < 0 then 0 else 1,
        x + (radius * cos(radians)),
        y + (radius * sin(radians))
      )
      if @percentArc
        arcAttributes.path = pathString
        @percentArc
          .stop()
          .animate(arcAttributes, ANIMATION_DURATION, 'linear')
      else
        @percentArc = paper.path(pathString).attr arcAttributes
        @addChild @percentArc

    # Small white circle on top of all
    unless @percentOverlay
      @percentOverlay = paper.circle(x, y, radius * 0.55).attr(
        fill: @configuration.color('indicatorPercentMiddle'),
        'stroke-opacity': 0
      )
      @addChild @percentOverlay

    return

  # Mouse event handling
  # --------------------

  addMouseHandlers: ->
    for displayObject in @displayObjects
      node = displayObject.node
      $(node).hover(@mouseenterHandler, @mouseleaveHandler) if node

  mouseenterHandler: =>
    @trigger 'mouseenter', this

  mouseleaveHandler: =>
    @trigger 'mouseleave', this

module.exports = IndicatorVisualization
