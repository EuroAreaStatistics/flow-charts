'use strict'
$ = require 'jquery'
Raphael = require 'raphael'
mediator = require 'mediator'
DisplayObject = require 'display_objects/display_object'
formatNumber = require 'lib/format_number'
scale = require 'lib/scale'
utils = require 'lib/utils'

# Shortcuts
# ---------

PI = Math.PI
HALF_PI = PI / 2

{sin, cos} = Math

INSIDE = 'inside'
OUTSIDE = 'outside'

OUTGOING = 'outgoing'
INCOMING = 'incoming'
PARTS = [OUTGOING, INCOMING]

EASE_OUT = 'easeOut'
EASE_IN = 'easeIn'

class Magnet extends DisplayObject

  # Constants
  # ---------

  # Marker length for charts with 1-2 elements
  MARKER_LENGTH = 10

  DIMMED_OUT_OPACITY = 0.5

  # Property declarations
  # ---------------------
  #
  # element: Element
  # model: ElementModel
  # configuration: Object
  #
  # outgoingBar: Raphael.Element
  # incomingBar: Raphael.Element
  #
  # labelPosition: String, INSIDE or OUTSIDE
  #   where to position the labels relative to the bars
  #   used in charts with more than two elements
  #
  # outgoingLabelPosition: String, INSIDE or OUTSIDE
  #   used in charts with up to two elements
  # incomingLabelPosition: String, INSIDE or OUTSIDE
  #   used in charts with up to two elements
  #
  # outgoingLabel: Raphael.Element
  # incomingLabel: Raphael.Element
  #   Volume labels on bars
  #
  # outgoingDescriptionLabel: Raphael.Element
  # incomingDescriptionLabel: Raphael.Element
  #
  # markerObjects: Array
  #   List which holds the relation marker objects
  #
  # deg: Number
  #   Angle in radian
  # degdeg: Number
  #   Angle in degree
  #
  # afterTransitionHandle: Number
  #   setTimeout handle for the deferred drawing call
  # fadeInHandle: Number
  #   setTimeout handle for the deferred fade in of new magnets
  # barsVisible: Boolean
  #   Whether the bars have been faded in.
  # lookAnimation: Raphael.Animation
  #   Current animation of the bar look, not the position
  #
  # labelsVisible: Boolean
  #   Whether the labels are visible all the time or only on highlight
  #
  # weight: Number
  #   Magnet thickness
  #
  # distanceToPrevious: Number
  #   Distance from point 1 to point 3 of the previous magnet
  # distanceToNext: Number
  #   Distance from point 3 to point 1 of the next magnet
  #
  # Drawing variables which are passed in:
  #
  # paper: Raphael.Paper
  # animationDuration: Number
  # chartDrawn: Boolean
  # elementCount: Number

  DRAW_OPTIONS: 'paper animationDuration chartDrawn elementCount'.split(' ')

  # Coordinates for drawing
  #
  #   4----------5----------6
  #   | outgoing | incoming |
  #   | (green)  | (red)    |
  #   1----------2----------3  <- inner edge facing to circle center

  x1: 0
  y1: 0

  x2: 0
  y2: 0

  x3: 0
  y3: 0

  x4: 0
  y4: 0

  x5: 0
  y5: 0

  x6: 0
  y6: 0

  constructor: (@element) ->
    super

    @markerObjects = []
    @barsVisible = false

    @initStates
      states:

        # Locking
        locked: ['on', 'off']

        # Highlighting and active states
        #   normal: neutral state
        #   highlight: highlighted temporarily by hover, activate relations
        #   active: highlighted permanently by click, activate relations
        #   dimmedOut: Dimmed out because another magnet is active
        mode: ['normal', 'highlight', 'active', 'dimmedOut']

      initialState:
        locked: 'off'
        mode: 'normal'

    # Print out states for debugging
    # @on 'leaveState', (magnet, oldState, newState) =>
    #   @outgoingLabel.attr text: newState.replace('mode', '')
    #   @outgoingLabel.attr text: ''

  # Sets the starting points
  # Called by the layouting algorithm
  # ---------------------------------

  setPosition: (@deg, @x1, @y1, @x3, @y3, grayBarRatio) ->
    # Calculate human-readable degree
    @degdeg = Raphael.deg @deg

    # Calculate point 2 early because other elements
    # need it before the magnet is drawn
    rate = @element.getRate()

    # Adjust position if some data is not available
    if @element.valueIsMissing(OUTGOING) and @element.valueIsMissing(INCOMING)
      rate = 0.5
    else if @element.valueIsMissing(OUTGOING)
      rate = grayBarRatio
    else if @element.valueIsMissing(INCOMING)
      rate = 1 - grayBarRatio

    @x2 = @x1 + ((@x3 - @x1) * rate)
    @y2 = @y1 + ((@y3 - @y1) * rate)

    return

  # Updating
  # --------

  update: (@model, @configuration) ->

  # Drawing
  # -------

  draw: (options) ->
    @saveDrawOptions options

    # Set the magnet thickness
    scalingMap = if @elementCount < 3
      'magnetSizeUpToTwo'
    else
      'magnetSize'
    @weight = scale scalingMap, @paper.width

    @calculateOuterPoints()
    @calculateAbsolutePoints()
    @calculateDistances options.previousElement, options.nextElement

    # Remove labels and markers during chart transition
    @removeLabels()
    @removeMarkers()

    @drawBars()

    # Clear timeouts
    clearTimeout @afterTransitionHandle
    clearTimeout @fadeInHandle

    # Calculate delay for drawing after the chart animation
    afterTransition = if @animationDuration > 0
      @animationDuration + 100
    else
      0

    # Draw labels and markers after the chart transition
    if @chartDrawn
      @afterTransitionHandle = utils.after afterTransition, @drawAfterTransition
    else
      @drawAfterTransition()

    # Fade in bars after the chart transition if the magnet was recently added
    if @chartDrawn and not @barsVisible
      @fadeInHandle = utils.after afterTransition, @fadeInBars

    @drawn = true
    return

  drawAfterTransition: =>
    @afterTransitionHandle = null
    @drawMarkers() if @elementCount < 3
    @drawLabels()
    return

  fadeInBars: =>
    @fadeInHandle = null
    # Respect dimmed-out state
    opacity = if @state('mode') is 'dimmedOut' then DIMMED_OUT_OPACITY else 1
    attributes = 'fill-opacity': opacity
    fadeDuration = @animationDuration / 2
    for part in PARTS
      @["#{part}Bar"].animate attributes, fadeDuration, EASE_OUT
    @barsVisible = true
    return

  # Calculate distances to previous and next magnets
  # Sets distanceToPrevious and distanceToNext
  # ------------------------------------------

  calculateDistances: (previousElement, nextElement) ->
    @distanceToPrevious = Math.sqrt(
      Math.pow(@x1 - previousElement.magnet.x3, 2) +
      Math.pow(@y1 - previousElement.magnet.y3, 2)
    )
    @distanceToNext = Math.sqrt(
      Math.pow(@x2 - nextElement.magnet.x1, 2) +
      Math.pow(@y2 - nextElement.magnet.y1, 2)
    )
    return

  # Calculate outer points for drawing (x4, x5, x6)
  # -----------------------------------------------

  calculateOuterPoints: ->
    distX = cos(@deg) * @weight
    distY = sin(@deg) * @weight

    @x4 = @x1 + distX
    @y4 = @y1 + distY

    @x5 = @x2 + distX
    @y5 = @y2 + distY

    @x6 = @x3 + distX
    @y6 = @y3 + distY

    return

  # Calculate absolute drawing points (absx[1-6], absy[1-6])
  # --------------------------------------------------------

  calculateAbsolutePoints: ->
    halfPaperWidth = @paper.width / 2
    halfPaperHeight = @paper.height / 2

    for i in [1..6]
      @["absx#{i}"] = @["x#{i}"] + halfPaperWidth
      @["absy#{i}"] = @["y#{i}"] + halfPaperHeight

    return

  # Draw the bars
  # -------------

  drawBars: ->
    @drawOutgoingBar()
    @drawIncomingBar()
    return

  drawOutgoingBar: ->
    pathString = "M #{@absx1}, #{@absy1},
      L #{@absx2}, #{@absy2},
      L #{@absx5}, #{@absy5},
      L #{@absx4}, #{@absy4} Z"
    @drawBar OUTGOING, pathString
    return

  drawIncomingBar: ->
    pathString = "M #{@absx2}, #{@absy2},
      L #{@absx3}, #{@absy3},
      L #{@absx6}, #{@absy6},
      L #{@absx5}, #{@absy5} Z"
    @drawBar INCOMING, pathString
    return

  drawBar: (part, pathString) ->
    barProperty = "#{part}Bar"

    # Get bar color.
    color = if @element.valueIsMissing(part)
      ['magnetMissingValueBg']
    else
      ['magnets', @model.dataType.type, part]
    color = @configuration.color color...

    if @drawn
      # Animate existing path, ensure the color is correct
      @[barProperty]
        .stop()
        .animate({fill: color, path: pathString}, @animationDuration, EASE_OUT)
      return

    # Start hidden when the magnet was added, fade in after chart transition
    opacity = if not @drawn and @chartDrawn then 0 else 1

    path = @paper.path(pathString).attr(
      fill: color
      'stroke-width': 0
      'stroke-opacity': 0
      # Start invisible
      'fill-opacity': opacity
    )
    @addChild path
    @[barProperty] = path

    @registerMouseHandlers path
    return

  # Draw the labels
  # ---------------

  drawLabels: ->
    @drawLabel part for part in PARTS
    if @elementCount < 3
      @drawDescriptionLabel part for part in PARTS
    @calculateLabelPosition()
    @hideLabels() unless @labelsVisible
    @positionLabel part for part in PARTS
    return

  # Draw labels (without positioning)
  # ---------------------------------

  # Creates the country label for the given part, positions it at 0,0
  # and saves it as @{part}Label
  drawLabel: (part) ->
    # Create the text elements
    number = @model[if part is OUTGOING then 'sumOut' else 'sumIn']
    text = ''

    {unit} = @model.dataType

    if @element.valueIsMissing(part)
      text = @t 'not_available'

    else
      number = formatNumber(
        @configuration, number, null, null, false
      )
      text = @template ['units', unit, 'value'], {number}

    scalingMap = if @elementCount < 3
      'magnetLabelSizeUpToTwo'
    else
      'magnetLabelSize'
    fontSize = scale scalingMap, @paper.width

    label = @paper
      # Position the label at 0,0 for a start
      .text(0, 0, text)
      .attr(
        fill: 'white'
        'font-family': 'inherit'
        'font-size': fontSize
        ' font-weight': 'bold'
      )

    @["#{part}Label"] = label
    @addChild label

    $(label.node)
      .hover(@mouseenterHandler, @mouseleaveHandler)
      .click(@clicked)

    return

  # Creates the description label for the given part, positions it at 0,0
  # and saves it as @{part}DescriptionLabel
  drawDescriptionLabel: (part) ->
    fontSize = scale 'magnetLabelSizeUpToTwo', @paper.width
    text = @t 'flow', @model.dataType.type, part
    label = @paper
      .text(0, 0, text)
      .attr(
        'font-family': 'inherit'
        'font-size': fontSize
      )
    @["#{part}DescriptionLabel"] = label
    @addChild label
    return

  # Calculate label position (inside or outside) and visibility
  # -----------------------------------------------------------

  # Set outgoingLabelPosition/incomingLabelPosition (up to 2 elements) or
  # labelPosition (3+ elements) and labelVisible
  calculateLabelPosition: ->
    if @elementCount < 3
      @calculateLabelPositionUpToTwo()
    else
      @calculateLabelPositionThreePlus()
    return

  # Set outgoingLabelPosition, incomingLabelPosition and labelsVisible
  # Width means y-size and height means x-size here since the bars
  # are rotated by 90°
  calculateLabelPositionUpToTwo: ->
    labelPositions = {}
    fontSize = scale 'magnetLabelSizeUpToTwo', @paper.width

    xPadding = fontSize / 2
    yPadding = fontSize

    # Check vertical fit
    labelsHeight = @getLabelsHeightUpToTwo() + yPadding * 2
    barWidths = @getBarWidths()
    for part in PARTS
      labelPositions[part] = if labelsHeight <= barWidths[part]
        INSIDE
      else
        OUTSIDE

    # Check horizontal fit
    labelWidths = @getLabelWidths()
    descriptionLabelWidths = @getDescriptionLabelWidths()

    for part in PARTS when labelPositions[part] is INSIDE
      labelWidth = Math.max(
        labelWidths[part], descriptionLabelWidths[part]
      ) + xPadding * 2
      labelPositions[part] = if labelWidth <= @weight
        INSIDE
      else
        OUTSIDE

    # Save the results
    for part in PARTS
      @["#{part}LabelPosition"] = labelPositions[part]

    # Labels are always visible
    @labelsVisible = true

    return

  # More than two elements
  # Set labelPosition and labelsVisible
  calculateLabelPositionThreePlus: ->
    # Calculate label positions (inside or outside)
    barWidths = @getBarWidths()
    labelWidths = @getLabelWidths()

    padding = 4

    labelWidthSum = labelWidths.sum + padding * 2
    barWidthSum = barWidths.sum

    @labelPosition = OUTSIDE

    # Hide labels in Nine-To-All charts. Hide outside labels if they would
    # overlap other magnets/labels. This is just an approximation.
    showOutsideLabels =
      @distanceToPrevious >= 1.8 * labelWidths.outgoing and
      @distanceToNext >= 1.8 * labelWidths.incoming

    # Visibility
    @labelsVisible =
      @elementCount < 9 and
      (@labelPosition is INSIDE or showOutsideLabels)

    return

  # Helpers to get the bar and label sizes
  # --------------------------------------

  # Get the net widths of the bars
  # Returns an object with `outgoing`, `incoming` and `sum` properties
  getBarWidths: ->
    widths = sum: 0
    for part in PARTS
      width = @getBarWidth part
      widths[part] = width
      widths.sum += width
    widths

  # Gets the bar width for the given part
  # For more than two elements
  getBarWidth: (part) ->
    if part is OUTGOING
      startX = @absx1; startY = @absy1
      endX = @absx2; endY = @absy2
    else
      startX = @absx2; startY = @absy2
      endX = @absx3; endY = @absy3

    Math.sqrt(Math.pow(endY - startY, 2) + Math.pow(endX - startX, 2))

  # Get the net widths of the country labels
  # Returns an object with `outgoing`, `incoming` and `sum` properties
  getLabelWidths: ->
    widths = sum: 0
    for part in PARTS
      width = @["#{part}Label"].getBBox().width
      widths[part] = width
      widths.sum += width
    widths

  # Get the net widths of the description labels (up to two elements)
  getDescriptionLabelWidths: ->
    widths = sum: 0
    for part in PARTS
      width = @["#{part}DescriptionLabel"].getBBox().width
      widths[part] = width
      widths.sum += width
    widths

  # Returns the height of the country *and* description labels
  getLabelsHeightUpToTwo: ->
    fontSize = scale 'magnetLabelSizeUpToTwo', @paper.width
    lineHeight = 1.2
    # Two lines (country label and type description label)
    2 * fontSize * lineHeight

  # Actual label positioning (set x/y position)
  # -------------------------------------------

  # Move the label for the given part to its final position
  positionLabel: (part) ->
    label = @["#{part}Label"]

    {x, y, textAnchor, textRotation} = @getLabelPosition part
    attributes = {x, y, 'text-anchor': textAnchor}

    if @elementCount < 3

      # Up to two elements
      # ------------------

      textColor = if @element.valueIsMissing(part)
        'magnetMissingValueFg'
      else if @["#{part}LabelPosition"] is OUTSIDE
        'fg'
      else
        'bg'
      textColor = @configuration.color textColor

      # Position and color description label
      fontSize = scale 'magnetLabelSizeUpToTwo', @paper.width
      lineHeight = 1.2
      y = y + fontSize * lineHeight
      @["#{part}DescriptionLabel"].attr {
        x,
        y,
        'text-anchor': textAnchor,
        fill: textColor
      }

    else

      # More than two elements
      # ----------------------

      textColor = if @element.valueIsMissing(part)
        ['magnetMissingValueFg']
      else if @labelPosition is OUTSIDE
        ['magnets', @element.model.dataType.type, part]
      else
        ['bg']
      textColor = @configuration.color textColor...

      # Apply text rotation
      label.transform "r#{textRotation}, #{x}, #{y}"

    # Apply label attributes
    attributes.fill = textColor
    label.attr attributes

    return

  # Returns an object with x, y, textAnchor and textRotation
  getLabelPosition: (part) ->
    if @elementCount < 3
      @getLabelPositionUpToTwo part
    else
      @getLabelPositionThreePlus part

  getLabelPositionUpToTwo: (part) ->
    isOutgoing = part is OUTGOING
    x = @absx6
    fontSize = scale 'magnetLabelSizeUpToTwo', @paper.width
    xOffset = scale 'magnetLabelXOffsetUpToTwo', @paper.width
    yOffset = fontSize

    if @degdeg > 0 # 180
      # Magnet on the left
      textAnchor = 'start'
      x += xOffset
      if isOutgoing
        if @outgoingLabelPosition is INSIDE
          y = @absy5
        else
          y = @absy4
        y += yOffset
      else
        if @incomingLabelPosition is INSIDE
          y = @absy6
          y += yOffset
        else
          y = @absy6 - @getLabelsHeightUpToTwo()
    else
      # Magnet on the right
      textAnchor = 'end'
      x -= xOffset
      if isOutgoing
        if @outgoingLabelPosition is INSIDE
          y = @absy4
          y += yOffset
        else
          y = @absy4 - @getLabelsHeightUpToTwo()
      else
        if @incomingLabelPosition is INSIDE
          y = @absy5
        else
          y = @absy6
        y += yOffset

    {x, y, textAnchor} # No text rotation

  getLabelPositionThreePlus: (part) ->
    {deg, degdeg} = this
    isOutgoing = part is OUTGOING

    # Calculate text anchor and rotation
    if degdeg >= 0 and degdeg <= 90
      textRotation = degdeg - 90
      textAnchor = if isOutgoing then 'end' else 'start'
    else if degdeg > 90 and degdeg < 180
      textRotation = degdeg - 90
      textAnchor = if isOutgoing then 'end' else 'start'
    else
      textRotation = degdeg + 90
      textAnchor = if isOutgoing then 'start' else 'end'

    # If the label is positioned outside, flip anchor position
    if @labelPosition is OUTSIDE
      textAnchor = if textAnchor is 'start' then 'end' else 'start'

    # Calculate x/y position
    if isOutgoing
      startX = @absx1; startY = @absy1
    else
      startX = @absx3; startY = @absy3

    factor =
      if isOutgoing
        if @labelPosition is INSIDE then 1 else -1
      else
        if @labelPosition is INSIDE then -1 else 1

    x = startX + (cos(deg) * (@weight / 2)) + factor * cos(deg + HALF_PI) * 5
    y = startY + (sin(deg) * (@weight / 2)) + factor * sin(deg + HALF_PI) * 5
    #@addChild @paper.circle(x, y, 1).attr(fill: 'blue', 'stroke-opacity': 0)

    {x, y, textAnchor, textRotation}

  # Remove the labels
  # -----------------

  removeLabels: ->
    for part in PARTS
      for suffix in ['Label', 'DescriptionLabel']
        prop = "#{part}#{suffix}"
        label = @[prop]
        if label
          @removeChild label
          delete @[prop]
    return

  # Change label visibility
  # -----------------------

  showLabels: ->
    for part in PARTS
      @["#{part}Label"]?.show().toFront()
    return

  hideLabels: ->
    for part in PARTS
      @["#{part}Label"]?.hide()
    return

  # Draw relation markers (short white line, short country label)
  # -------------------------------------------------------------

  drawMarkers: ->
    @drawOutgoingMarkers()
    @drawIncomingMarkers()
    return

  drawOutgoingMarkers: ->
    relations = @element.relationsOut
    drawnRelations = []
    couldDrawMarker = true
    for relation in relations

      if relation.to
        # Draw a marker without a label for normal relations
        @drawNormalMarker relation, false
        drawnRelations.push relation

      else if couldDrawMarker
        # Draw a marker for relations without a destination element
        couldDrawMarker = @drawNormalMarker relation, true
        drawnRelations.push relation if couldDrawMarker

    # For the remaining undrawn relations, draw an “others” segment
    @drawOthersMarker drawnRelations, OUTGOING
    return

  drawIncomingMarkers: ->
    relations = @element.relationsIn
    drawnRelations = []
    couldDrawMarker = true
    for relation in relations
      # Draw unless it fails
      drawLabel = not relation.from
      couldDrawMarker = @drawNormalMarker relation, drawLabel
      if couldDrawMarker or relation.from
        drawnRelations.push relation
      break unless couldDrawMarker

    # For the remaining undrawn relations, draw an “others” segment
    @drawOthersMarker drawnRelations, INCOMING
    return

  # Draw a marker for an incoming or outgoing relation
  # Returns whether the marker could be drawn (Boolean)
  drawNormalMarker: (relation, drawLabel) ->
    isOutgoing = relation.from is @element
    direction = if isOutgoing then OUTGOING else INCOMING
    position = @element.getRelationPosition relation
    if drawLabel
      labelText = if isOutgoing then relation.toId else relation.fromId
      labelText = labelText.toUpperCase()
    else
      labelText = ''
    @drawMarker direction, position, relation.value, labelText

  # Draw an “others” segment for the remaining volume
  drawOthersMarker: (drawnRelations, direction) ->
    return if drawnRelations.length < 2
    reducer = (memo, relation) -> memo + relation.value
    drawnSum = _.reduce drawnRelations, reducer, 0
    sum = if direction is OUTGOING
      @element.model.sumOut
    else
      @element.model.sumIn
    position = drawnSum / sum
    # The undrawn rest
    undrawnSum = sum - drawnSum
    return if undrawnSum is 0
    labelText = @t 'magnet', 'one_to_one_others'
    @drawMarker direction, position, undrawnSum, labelText
    return

  # Internal reusable method for drawing a marker
  # Returns whether the marker could be drawn (Boolean)
  drawMarker: (direction, position, relationValue, labelText) ->
    {degdeg} = this
    isLeft = degdeg is 180
    isOutgoing = direction is OUTGOING

    # Calculate x, start y and end y position
    if isLeft
      if isOutgoing
        # Draw inside of outgoing part
        x = @absx2
        startY = @absy2
        endY = @absy1
      else
        # Draw inside of incoming part
        x = @absx3
        startY = @absy3
        endY = @absy2
    else
      if isOutgoing
        # Draw inside of outgoing part
        x = @absx1
        startY = @absy1
        endY = @absy2
      else
        # Draw inside of incoming part
        x = @absx2
        startY = @absy2
        endY = @absy3

    ySpan = endY - startY
    y1 = startY + (ySpan * position)
    sum = if direction is OUTGOING
      @element.model.sumOut
    else
      @element.model.sumIn
    y2 = y1 + (ySpan * (relationValue / sum))
    yDist = Math.abs y2 - y1

    # Stop if there’s not enough space for the marker
    if yDist < 4
      return false

    # Draw the marker line
    unless position is 0
      pathString = Raphael.format(
        'M{0},{1} L{2},{3}',
        x, y1,
        x + (if isLeft then -1 else 1) * MARKER_LENGTH, y1
      )
      path = @paper.path(pathString).attr(
        stroke: 'white'
        'stroke-opacity': 1
      )
      @addChild path
      @markerObjects.push path

    # Stop if there’s not enough space for the marker
    if yDist < 10
      return true

    # Label positioning
    if labelText
      if isLeft
        textAnchor = 'start'
        textX = x + 5
      else
        textAnchor = 'end'
        textX = x - 5
      textY = (y1 + y2) / 2

      label = @paper
        .text(textX, textY, labelText)
        .attr(
          fill: 'rgb(180, 180, 180)'
          'font-family': 'inherit'
          'font-size': 10
          'text-anchor': textAnchor
        )
      @addChild label
      @markerObjects.push label

    return true

  removeMarkers: ->
    for object in @markerObjects
      @removeChild object
    @markerObjects = []
    return

  # Content box methods
  # -------------------

  showContextBox: ->
    pos = @element.indicators.countryLabel.getBBox()
    mediator.publish 'contextbox:explainMagnet',
      parent: @element.$container.parent()
      elementModel: @element.model
      x: pos.x
      y: pos.y2
    return

  hideContextBox: ->
    mediator.publish 'contextbox:hide'
    return

  # Mouse event handling
  # --------------------

  registerMouseHandlers: (path) ->
    $(path.node)
      .hover(@mouseenterHandler, @mouseleaveHandler)
      .click(@clicked)
    return

  mouseenterHandler: =>
    currentState = @state 'mode'

    # If the magnet is already highlighted, do nothing.
    return if currentState is 'highlight'

    # Fade in content box
    @showContextBox()

    # Change state
    unless currentState is 'active'
      @transitionTo 'mode', 'highlight'

    return

  mouseleaveHandler: (event) =>
    relatedTarget = event.relatedTarget

    # Check if the mouse target is bar of the magnet
    targetIsChild = _.some @displayObjects, (obj) ->
      node = obj.node
      node and (relatedTarget is node or $.contains(node, relatedTarget))
    return if targetIsChild

    # Fade out content box
    @hideContextBox()

    # We can’t decide the new state, handle this in ChartStates.
    @trigger 'mouseleave', this

    return

  clicked: =>
    # Toggle locking
    if @state('locked') is 'on'
      @transitionTo 'mode', 'highlight'
      @transitionTo 'locked', 'off'
    else
      @transitionTo 'mode', 'active'
      @transitionTo 'locked', 'on'

    @trigger 'click', this
    return

  # Transitions
  # -----------

  enterModeNormalState: (oldState) ->
    return unless oldState
    @removeDim()
    # Hide labels again if they are invisible per default
    @hideLabels() unless @labelsVisible
    return

  enterModeDimmedOutState: ->
    @dimOut()
    # Hide labels again if they are invisible per default
    @hideLabels() unless @labelsVisible
    return

  enterModeHighlightState: ->
    @removeDim()
    # Show labels temporarily
    @showLabels() unless @labelsVisible
    return

  enterModeActiveState: ->
    @removeDim()
    # Show labels temporarily
    @showLabels() unless @labelsVisible
    return

  # Transitions helpers
  # -------------------

  dimOut: ->
    # No opacity changes while waiting to fade in
    return if @fadeInHandle
    @animateBarLook(
      { 'fill-opacity': DIMMED_OUT_OPACITY },
      @animationDuration / 4,
      EASE_OUT
    )
    return

  removeDim: ->
    # No opacity changes while waiting to fade in
    return if @fadeInHandle
    @animateBarLook(
      { 'fill-opacity': 1 },
      @animationDuration / 4,
      EASE_IN
    )
    return

  # Helper for the bar look animation (not the position).
  # Ensures that only one look animation is running.
  animateBarLook: (attributes, duration, easing) ->
    if @lookAnimation
      @outgoingBar.stop @lookAnimation
      @incomingBar.stop @lookAnimation
    @lookAnimation = Raphael.animation attributes, duration, easing
    @outgoingBar.animate @lookAnimation
    @incomingBar.animate @lookAnimation
    return

  # Fade out before disposal
  fadeOut: ->
    for child in @displayObjects when child.stop and child.animate
      child.stop().animate { opacity: 0 }, @animationDuration / 2
    return

  # Disposal
  # --------

  dispose: ->
    return if @disposed
    clearTimeout @afterTransitionHandle
    clearTimeout @fadeInHandle
    super

module.exports = Magnet
