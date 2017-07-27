'use strict'
$ = require 'jquery'
_ = require 'lodash'
Raphael = require 'raphael'
mediator = require 'mediator'
DisplayObject = require 'display_objects/display_object'
formatNumber = require 'lib/format_number'
utils = require 'lib/utils'

# Shortcuts
# ---------

PI = Math.PI
HALF_PI = PI / 2

{sin, cos, atan2} = Math

EASE_IN = 'easeIn'
EASE_OUT = 'easeOut'

# Constants
# ---------

ARROW_SIZE = 10
PERCENT_LABEL_DISTANCE = 20
NORMAL_OPACITY = 0.25
ACTIVE_OPACITY = 0.9
HIGHLIGHT_OPACITY = 1

class Relation extends DisplayObject

  # Property declarations
  # ---------------------
  #
  # id: String
  #   from and to ID connected with a “>”, like fr>us
  # configuration: Object
  #
  # fromId: String
  # from: Element
  # toId: String
  # to: Element
  #
  # value: Number
  # positionOut: Number
  # positionIn: Number
  # missingRelations: Object
  #
  # $container: jQuery
  #
  # path: Raphael.Element
  # destinationArrow: Raphael.Element
  # sourceArrow: Raphael.Element
  #
  # labelContainer: jQuery
  # sourceLabel: jQuery
  # destinationLabel: jQuery
  # valueBox: Object
  # descriptionBox: Object
  #
  # fadeDuration: Number
  # lookAnimation: Raphael.Animation
  #   Current animation of the path look, not the position
  #
  # Drawing variables which are passed in:
  #
  # paper: Raphael.Paper
  # animationDuration: Number
  # chartDrawn: Boolean

  DRAW_OPTIONS: 'paper $container animationDuration chartDrawn'.split(' ')

  # Properties that are creating during drawing, e.g. DOM elements
  DRAW_PROPERTIES: 'path destinationArrow sourceArrow labelContainer ' +
    'valueBox descriptionBox fadeDuration lookAnimation ' +
    'animationDeferred'.split(' ')

  constructor: (options) ->
    super

    {@fromId, @from, @toId, @to} = options
    @id = "#{@fromId}>#{@toId}"

    @initStates
      states:

        # Locking
        locked: ['on', 'off']

        # Path states
        #   normal: light gray
        #   highlight: highlighted temporarily by hover, dark gray
        #   active: highlighted permanently by click, dark gray
        #   activeIn: red incoming relation, green arrow at source
        #   activeOut: green outgoing relation,
        #              green arrows at source and destination
        path: ['normal', 'highlight', 'active', 'activeIn', 'activeOut'],

        # labels states
        #   on: display labels
        #   off: hide labels
        labels: ['on', 'off']

      initialState:
        locked: 'off'
        path: 'normal'
        labels: 'off'

  # Updating
  # --------

  update: (options) ->
    # Update `to` as well since it might change
    {@configuration, @to, @value, @positionOut, @positionIn,
      @missingRelations} = options
    return

  # Drawing
  # -------

  draw: (options, drawInverseFrom = false, drawInverseTo = false) ->
    @saveDrawOptions options

    # Remove from DOM if invisible
    if not @visible and @drawn
      @reset()
      return

    # Only draw visible relations that are connected to elements
    return unless @visible and @from and @to

    @fadeDuration = @animationDuration / 2

    fromMagnet = @from.magnet
    toMagnet = @to.magnet

    {value, positionIn, positionOut} = this

    fromSumOut = @from.model.sumOut
    toSumIn = @to.model.sumIn

    # Fix for inner-country relations in charts with 1-2 elements
    if @from is @to
      drawInverseTo = drawInverseFrom

    offset =
      x: @paper.width / 2
      y: @paper.height / 2

    # Points of source and destination magnets
    source =
      start:
        x: unless drawInverseFrom then fromMagnet.x1 else fromMagnet.x2
        y: unless drawInverseFrom then fromMagnet.y1 else fromMagnet.y2
      end:
        x: unless drawInverseFrom then fromMagnet.x2 else fromMagnet.x1
        y: unless drawInverseFrom then fromMagnet.y2 else fromMagnet.y1
    destination =
      start:
        x: unless drawInverseTo then toMagnet.x2 else toMagnet.x3
        y: unless drawInverseTo then toMagnet.y2 else toMagnet.y3
      end:
        x: unless drawInverseTo then toMagnet.x3 else toMagnet.x2
        y: unless drawInverseTo then toMagnet.y3 else toMagnet.y2

    source.length = Math.sqrt(
      Math.pow(source.end.x - source.start.x, 2) +
      Math.pow(source.end.y - source.start.y, 2)
    )

    # Relation line start and end point
    relationLine =
      start:
        x: @relationMiddlePointX(source, fromSumOut, value, positionOut, offset)
        y: @relationMiddlePointY(source, fromSumOut, value, positionOut, offset)
      end:
        x: @relationMiddlePointX(destination, toSumIn, value, positionIn, offset)
        y: @relationMiddlePointY(destination, toSumIn, value, positionIn, offset)
      # pathString will be added

    # Distance from startFace.start <-> destinationFace.start
    distance = Math.sqrt(
      Math.pow(relationLine.end.y - relationLine.start.y, 2) +
      Math.pow(relationLine.end.x - relationLine.start.x, 2)
    )

    controlPointDistance = distance * 0.4

    # Trigonometry for control points
    degrees = {}
    degrees.start = {}
    degrees.start.deg = if drawInverseFrom
      atan2(source.start.y - source.end.y, source.start.x - source.end.x) - HALF_PI
    else
      atan2(source.end.y - source.start.y, source.end.x - source.start.x) - HALF_PI
    degrees.start.cos = cos degrees.start.deg
    degrees.start.sin = sin degrees.start.deg
    degrees.start.distCos = degrees.start.cos * controlPointDistance
    degrees.start.distSin = degrees.start.sin * controlPointDistance

    degrees.end = {}
    degrees.end.deg = if drawInverseTo
      atan2(destination.start.y - destination.end.y, destination.start.x - destination.end.x) - HALF_PI
    else
      atan2(destination.end.y - destination.start.y, destination.end.x - destination.start.x) - HALF_PI
    degrees.end.cos = cos degrees.end.deg
    degrees.end.sin = sin degrees.end.deg
    degrees.end.distCos = degrees.end.cos * controlPointDistance
    degrees.end.distSin = degrees.end.sin * controlPointDistance

    # Calculate Bézier control points for start and end
    controlPoint =
      start:
        x: relationLine.start.x - degrees.start.distCos
        y: relationLine.start.y - degrees.start.distSin
      end:
        x: relationLine.end.x - degrees.end.distCos
        y: relationLine.end.y - degrees.end.distSin

    # Curve from start through both control points to end
    relationLine.pathString =
      'M' + relationLine.start.x + ',' + relationLine.start.y +
      'C' + controlPoint.start.x + ',' + controlPoint.start.y +
      ' ' + controlPoint.end.x + ',' + controlPoint.end.y +
      ' ' + relationLine.end.x + ',' + relationLine.end.y

    strokeWidth = (source.length / fromSumOut) * @value
    strokeWidth = Math.max strokeWidth, 0.8

    # Finally draw the paths
    # ----------------------

    # Initialize Deferred which tracks whether all parts have been drawn
    @animationDeferred?.reject()
    @animationDeferred = $.Deferred()

    # Curry the drawArrows function to use it as an animation callback
    drawArrows = _.bind(
      @drawArrows,
      this,
      source, destination, degrees, offset
    )

    if @drawn
      # Hide the arrows during the animation
      @hideArrows()

      # Animate existing path, stop all running animations
      @path.stop().animate(
        { path: relationLine.pathString, 'stroke-width': strokeWidth },
        @animationDuration,
        EASE_OUT,
        # Move arrows after animation
        drawArrows
      )
      return

    # Path hasn’t been drawn before, create it from scratch
    @path = @paper.path(relationLine.pathString).attr(
      stroke: @relationColor()
      'stroke-opacity': if @chartDrawn then 0 else NORMAL_OPACITY
      'stroke-width': strokeWidth
      #'stroke-dasharray': '.' # N/A
    )
    @addChild @path

    # If the relation belongs to a country which was recently added
    # to the chart, fade in the path
    if @chartDrawn
      afterTransition = if @animationDuration > 0
        @animationDuration + 100
      else
        0
      animation = Raphael.animation(
        { 'stroke-opacity': NORMAL_OPACITY },
        @fadeDuration,
        EASE_OUT,
        # Draw arrows after animation
        drawArrows
      ).delay(afterTransition)
      @path.animate animation
    else
      # Immediately draw the arrows
      drawArrows()
      @animationDeferred.resolve()

    @registerMouseHandlers()

    @drawn = true
    return

  # Helpers for getting the start and end points of the relation line
  #
  #               Magnet
  # +------------------+---------------+
  # |                  |               |
  # +----o----+--------+---------------+
  # \          \
  #   \          \    Relation
  #     \          \
  #
  # ^-- Start point
  #      ^-- Middle point
  #           ^-- End point

  relationPoint: (dimension, point, absPosition, offset) ->
    point.start[dimension] + absPosition + offset[dimension]

  relationStartPoint: (dimension, point, total, value, position, offset) ->
    length = point.end[dimension] - point.start[dimension]
    absPosition = position * length
    @relationPoint dimension, point, absPosition, offset

  relationMiddlePoint: (dimension, point, total, value, position, offset) ->
    length = point.end[dimension] - point.start[dimension]
    absPosition = (position * length) + value / 2 / total * length
    @relationPoint dimension, point, absPosition, offset

  relationEndPoint: (dimension, point, total, value, position, offset) ->
    length = point.end[dimension] - point.start[dimension]
    absPosition = (position * length) + value / total * length
    @relationPoint dimension, point, absPosition, offset

  relationStartPointX: (point, total, value, position, offset) ->
    @relationStartPoint 'x', point, total, value, position, offset

  relationStartPointY: (point, total, value, position, offset) ->
    @relationStartPoint 'y', point, total, value, position, offset

  relationMiddlePointX: (point, total, value, position, offset) ->
    @relationMiddlePoint 'x', point, total, value, position, offset

  relationMiddlePointY: (point, total, value, position, offset) ->
    @relationMiddlePoint 'y', point, total, value, position, offset

  relationEndPointX: (point, total, value, position, offset) ->
    @relationEndPoint 'x', point, total, value, position, offset

  relationEndPointY: (point, total, value, position, offset) ->
    @relationEndPoint 'y', point, total, value, position, offset

  # Removes all elements from the DOM, returns to undrawn state.
  reset: ->
    @animationDeferred?.reject()
    @removeChildren()
    delete @[prop] for prop in @DRAW_PROPERTIES
    @drawn = false
    return

  # Configuration shortcuts

  relationColor: ->
    @configuration.color 'relation'

  incomingColor: ->
    @configuration.color(
      'magnets', @from.model.dataType.type, 'incoming'
    )

  outgoingColor: ->
    @configuration.color(
      'magnets', @from.model.dataType.type, 'outgoing'
    )

  # Drawing the arrows
  # ------------------

  drawArrows: (source, destination, degrees, offset) =>
    # Calculate path strings
    sourcePathString = @getSourceArrowPath(
      source, offset, degrees
    )
    destinationArrowPathString = @getDestinationArrowPath(
      destination, offset, degrees
    )

    if @sourceArrow and @destinationArrow
      # Just move the existing arrows without animation
      @sourceArrow.attr path: sourcePathString
      @destinationArrow.attr path: destinationArrowPathString
      @animationDeferred.resolve()
      return

    # Draw arrows from scratch
    @sourceArrow = @paper.path(sourcePathString)
      .hide() # Start hidden
      # The source arrow never changes its color
      .attr(fill: @outgoingColor(), 'stroke-opacity': 0)
    @addChild @sourceArrow

    @destinationArrow = @paper.path(destinationArrowPathString)
      .hide() # Start hidden
      .attr(fill: @relationColor(), 'stroke-opacity': 0)
    @addChild @destinationArrow

    @animationDeferred.resolve()

    return

  # The arrows are isosceles triangles:
  #       C
  #       +
  #     /   \
  #   /       \
  #  +---------+
  #  A         B

  getSourceArrowPath: (source, offset, degrees) ->
    fromSumOut = @from.model.sumOut
    {value, positionOut} = this

    a =
      x: @relationStartPointX(source, fromSumOut, value, positionOut, offset)
      y: @relationStartPointY(source, fromSumOut, value, positionOut, offset)
    b =
      x: @relationEndPointX(source, fromSumOut, value, positionOut, offset)
      y: @relationEndPointY(source, fromSumOut, value, positionOut, offset)

    c =
      x: a.x + (b.x - a.x) / 2 - degrees.start.cos * ARROW_SIZE
      y: a.y + (b.y - a.y) / 2 - degrees.start.sin * ARROW_SIZE

    sourceArrowPath =
      'M' + a.x + ',' + a.y +
      'L' + b.x + ',' + b.y +
      'L' + c.x + ',' + c.y

    sourceArrowPath

  getDestinationArrowPath: (destination, offset, degrees) ->
    toSumIn = @to.model.sumIn
    {value, positionIn} = this

    a =
      x: @relationStartPointX(destination, toSumIn, value, positionIn, offset)
      y: @relationStartPointY(destination, toSumIn, value, positionIn, offset)
    b =
      x: @relationEndPointX(destination, toSumIn, value, positionIn, offset)
      y: @relationEndPointY(destination, toSumIn, value, positionIn, offset)

    c =
      x: a.x + (b.x - a.x) / 2 + degrees.end.cos * ARROW_SIZE
      y: a.y + (b.y - a.y) / 2 + degrees.end.sin * ARROW_SIZE

    destinationArrowPath =
      'M' + a.x + ',' + a.y +
      'L' + b.x + ',' + b.y +
      'L' + c.x + ',' + c.y

    destinationArrowPath

  hideArrows: ->
    @sourceArrow.hide() if @sourceArrow
    @destinationArrow.hide() if @destinationArrow
    return

  # Content box methods
  # -------------------

  showContextBox: ->
    mediator.publish 'contextbox:explainRelation',
      {@from, @to, @value, @missingRelations}
    return

  hideContextBox: ->
    mediator.publish 'contextbox:hide'
    return

  # Mouse event handling
  # --------------------

  registerMouseHandlers: ->
    $(@path.node)
      .mouseenter(@mouseenterHandler)
      .mouseleave(@mouseleaveHandler)
      .click(@clicked)

  mouseenterHandler: =>
    # Fade in content box
    @showContextBox()

    # Highlight if normal
    if @state('path') is 'normal'
      @transitionTo 'path', 'highlight'

    # Show labels in any case
    @transitionTo 'labels', 'on'
    return

  mouseleaveHandler: (event) =>
    relatedTarget = event.relatedTarget

    # Stop if the target is the relation path
    if _.some(@displayObjects, (obj) -> relatedTarget is obj.node) or
      @labelContainer and $.contains(@labelContainer.get(0), relatedTarget)
        return

    # Fade out content box
    @hideContextBox()

    pathState = @state 'path'

    # Reset if highlighted
    if pathState is 'highlight'
      @transitionTo 'path', 'normal'

    # Hide labels if not active
    unless pathState is 'active'
      @transitionTo 'labels', 'off'
    return

  clicked: =>
    # Toggle locking
    if @state('locked') is 'on'
      @transitionTo 'path', 'highlight'
      @transitionTo 'locked', 'off'
    else
      @transitionTo 'path', 'active'
      @transitionTo 'locked', 'on'
    return

  # Transitions
  # -----------

  # Path transition handlers
  # ------------------------

  enterPathNormalState: (oldState) ->
    return unless oldState and @drawn
    @setNormalLook()

  enterPathHighlightState: ->
    @setHighlightLook() if @drawn

  enterPathActiveState: ->
    @setHighlightLook() if @drawn

  enterPathActiveInState: ->
    @setActiveInLook() if @drawn

  enterPathActiveOutState: ->
    @setActiveOutLook() if @drawn

  # Labels transition handlers
  # --------------------------

  enterLabelsOnState: ->
    @createLabels() if @drawn

  enterLabelsOffState: ->
    @removeLabels() if @drawn

  # Transitions helpers
  # -------------------

  # Normal look: Gray translucent path, no arrows
  setNormalLook: ->
    @animatePathLook(
      {
        stroke: @relationColor()
        'stroke-opacity': NORMAL_OPACITY
      },
      @fadeDuration,
      EASE_IN
    )
    @hideArrows()
    return

  # Highlighted: Gray opaque path, both arrows visible,
  # gray destination arrow
  setHighlightLook: ->
    color = @relationColor()
    # Wait for animation to complete
    @animationDeferred.done =>
      @path.toFront()
      @animatePathLook(
        { stroke: color, 'stroke-opacity': HIGHLIGHT_OPACITY },
        @fadeDuration,
        EASE_OUT
      )
      @sourceArrow.stop().attr('fill-opacity': HIGHLIGHT_OPACITY)
        .toFront().show()
      @destinationArrow.stop().toFront().show().animate(
        { fill: color, 'fill-opacity': HIGHLIGHT_OPACITY },
        @fadeDuration,
        EASE_OUT
      )
      return
    return

  # Active in: Red translucent path, only show source arrow
  setActiveInLook: ->
    @animationDeferred.done =>
      color = @incomingColor()
      @animatePathLook(
        { stroke: color, 'stroke-opacity': ACTIVE_OPACITY },
        @fadeDuration,
        EASE_OUT
      )
      @sourceArrow.stop().toFront().show().animate(
        { 'fill-opacity': 0.25 },
        @fadeDuration,
        EASE_OUT
      )
      @destinationArrow.stop().hide()
      return
    return

  # Active out: Green translucent path, both arrows visible,
  # green destination arrow
  setActiveOutLook: ->
    @animationDeferred.done =>
      color = @outgoingColor()
      @animatePathLook(
        { stroke: color, 'stroke-opacity': ACTIVE_OPACITY },
        @fadeDuration,
        EASE_OUT
      )
      @sourceArrow.stop().toFront().show().animate(
        { 'fill-opacity': 1 },
        @fadeDuration,
        EASE_OUT
      )
      @destinationArrow.stop().toFront().show().animate(
        { fill: color, 'fill-opacity': ACTIVE_OPACITY },
        @fadeDuration,
        EASE_OUT
      )
      return
    return

  # Helper for the path look animation (not the path itself).
  # Ensures that only one look animation is running.
  animatePathLook: (attributes, duration) ->
    return unless @path
    @path.stop @lookAnimation if @lookAnimation
    @lookAnimation = Raphael.animation attributes, duration, EASE_OUT
    @path.animate @lookAnimation
    return

  # Create labels
  # -------------

  createLabels: ->
    # Don’t create the labels twice
    return if @labelContainer

    # Get a point at the middle of the path to position the labels
    pathLength = @path.getTotalLength()
    middleOfPath = @path.getPointAtLength pathLength / 2

    @createLabelContainer()
    @createValueLabel middleOfPath
    @createDescriptionLabel middleOfPath
    @createSourceLabel()
    @createDestinationLabel()
    @positionSourceDestinationLabels pathLength
    return

  createLabelContainer: ->
    @labelContainer = $('<div>')
      .addClass('relation-labels')
      # Check target when the mouse leaves the labels
      .mouseleave(@mouseleaveHandler)
      # Allow activation by clicking on a label
      .click(@clicked)
      # Append to DOM
      .appendTo(@$container)
    @addChild @labelContainer
    return

  createValueLabel: (middleOfPath) ->
    {from} = this

    number = formatNumber(
      @configuration, @value, null, null, true
    )
    text = @template(
      ['units', from.model.dataType.unit, 'value_html']
      number: number
    )

    value = $('<div>')
      .addClass('relation-value-label')
      .append(text)
      # Append immediately to get the size
      .appendTo(@labelContainer)

    # Calculate bounding box
    width = value.outerWidth()
    height = value.outerHeight()
    x = middleOfPath.x - width / 2
    y = middleOfPath.y - height - 1.5
    x2 = x + width
    y2 = y + height
    @valueBox = {width, height, x, y, x2, y2}

    value.css left: x, top: y
    return

  createDescriptionLabel: (middleOfPath) ->
    {from, to} = this

    type = from.model.dataType.type

    text = @template ['flow', type, 'fromTo'], {
      from: @t('entityNames', from.id)
      to: @t('entityNames', to.id)
    }

    description = $('<div>')
      .addClass('relation-description-label')
      .html(text)
      # Append immediately to get the size
      .appendTo(@labelContainer)

    # Calculate bounding box
    width = description.outerWidth()
    height = description.outerHeight()
    x = middleOfPath.x - width / 2
    y = middleOfPath.y + 1.5
    x2 = x + width
    y2 = y + height
    @descriptionBox = {width, height, x, y, x2, y2}

    description.css left: x, top: y
    return

  createSourceLabel: ->
    @sourceLabel = @createSourceDestinationLabel @from.model.sumOut
    return

  createDestinationLabel: ->
    @destinationLabel = @createSourceDestinationLabel @to.model.sumIn
    return

  createSourceDestinationLabel: (value) ->
    if @value < 0
      text = ''
    else
      text = (100 / value * @value).toFixed(1) + ' %'
    $('<div>')
      .addClass('relation-percentage-label')
      .text(text)
      # Append immediately to get the size
      .appendTo(@labelContainer)

  positionSourceDestinationLabels: (pathLength) ->
    {from, to, path} = this

    # Calculate source bounding box
    point = path.getPointAtLength PERCENT_LABEL_DISTANCE
    srcBox = @labelBoundingBox @sourceLabel, point

    # Calculate destination bounding box
    point = path.getPointAtLength pathLength - PERCENT_LABEL_DISTANCE
    destBox = @labelBoundingBox @destinationLabel, point

    # If one box intersects with value/description,
    # move both over their magnets

    labelsIntersect =
      Raphael.isBBoxIntersect(srcBox, @valueBox) or
      Raphael.isBBoxIntersect(srcBox, @descriptionBox) or
      Raphael.isBBoxIntersect(destBox, @valueBox) or
      Raphael.isBBoxIntersect(destBox, @descriptionBox)

    if labelsIntersect

      dist = PERCENT_LABEL_DISTANCE

      # Move source label
      point = path.getPointAtLength 0
      deg = from.magnet.deg
      srcBox.x = point.x + cos(deg) * dist - srcBox.width / 2
      srcBox.y = point.y + sin(deg) * dist - srcBox.height / 2

      # Move destination label
      point = path.getPointAtLength pathLength
      deg = to.magnet.deg
      destBox.x = point.x + cos(deg) * dist - destBox.width / 2
      destBox.y = point.y + sin(deg) * dist - destBox.height / 2

    # Finally set their position
    @sourceLabel.css left: srcBox.x, top: srcBox.y
    @destinationLabel.css left: destBox.x, top: destBox.y

    return

  labelBoundingBox: (label, point) ->
    box =
      width: label.outerWidth()
      height: label.outerHeight()
    box.x = point.x - box.width / 2
    box.y = point.y - box.height / 2
    box.x2 = box.x + box.width
    box.y2 = box.y + box.height
    box

  # Remove labels
  # -------------

  removeLabels: ->
    return unless @labelContainer
    @labelContainer.remove()
    @removeChild @labelContainer
    delete @labelContainer

  # Fade out before disposal
  fadeOut: ->
    for child in @displayObjects when child.stop and child.animate
      child.stop().animate { opacity: 0 }, @animationDuration / 2
    return

  # Disposal
  # --------

  dispose: ->
    return if @disposed

    # Remove references from elements
    @from.removeRelationOut this if @from
    @to.removeRelationIn this if @to

    # Stop the animation Deferred
    @animationDeferred.reject() if @animationDeferred

    super

module.exports = Relation
