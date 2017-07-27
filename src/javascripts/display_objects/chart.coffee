'use strict'
_ = require 'lodash'
$ = require 'jquery'
Raphael = require 'raphael'
DisplayObject = require 'display_objects/display_object'
ChartStates = require 'display_objects/chart_states'
ChartDrawing = require 'display_objects/chart_drawing'
ChartElements = require 'display_objects/chart_elements'
ChartRelations = require 'display_objects/chart_relations'
utils = require 'lib/utils'

Raphael.easing_formulas.chartEaseOut = (n) -> Math.pow(n, 0.1)

class Chart extends DisplayObject

  # Support detection (used in the Player)
  @canUse = do ->
    # The browser must support VML or SVG
    Raphael.type isnt '' and
    # But exclude IE 6 and 7 so they get the static chart
    not /MSIE [67]\.0/.test(navigator.userAgent)

  # Mixin the submodules
  # --------------------

  _.extend @prototype,
    ChartStates, ChartDrawing, ChartElements, ChartRelations

  # Property declarations
  # ---------------------

  # $container: jQuery
  # animationDuration: Number
  # keyframe: Keyframe
  #   The main data source
  # configuration: Object
  # dataType: Object
  # elements: Array.<Element>
  #   The main element list
  # elementsById: Object.<Element>
  #   Current elements by ID
  # elementIdsChanged: Boolean
  #   Flag that indicates whether element IDs changed since the last update
  #   (i.e. elements were added, removed or moved)
  # format: utils.FORMAT_DEFAULT or utils.FORMAT_THUMBNAIL
  #   Normal or compact rendering (used for static images)
  # radius: Number
  #   The chart radius
  # maxSum: Number
  #   Maximum data value that is used for magnet scaling
  # initLockingHandle: Number
  #   setTimeout handle for restoring the locking after chart transition
  # updateDisabled: Boolean
  #   Flag that is enabled while setting locks to prevent recursion
  # lockingPublisherMuted: Boolean
  #   Flag that is enabled while resetting states to prevent recursion
  # elementCountError: Raphael.Element
  #   When no elements are present, this is the error message

  constructor: (options) ->
    super
    @initChartStates()

    # Limit calls to resize
    @resize = _.throttle @resize, 100

    # Wrap the container in a jQuery object
    $container = $(options.container)
    @$container = $container

    # Set up animation duration
    @animationDuration = options.animationDuration ? 1000

    # Determine the format
    @format = options.format ? utils.FORMAT_DEFAULT

    @createPaper()

  # (Re-)Create the main drawing paper
  createPaper: ->
    # Remove existing paper
    @removeChild @paper if @paper

    # Create the new paper
    @paper = Raphael(
      @$container.get(0), @$container.width(), @$container.height()
    )
    @addChild @paper

    # Listen for clicks on the canvas
    $(@paper.canvas).click _.bind(@canvasClicked, this)

    return

  # On window resize, redraw the whole chart
  resize: =>
    @redraw() if @drawn
    return

  # Update the chart to represent a keyframe
  update: (options) ->
    return if @updateDisabled
    clearTimeout @initLockingHandle

    {keyframe} = options
    @keyframe = keyframe

    @configuration = keyframe.get 'configuration'

    # Get max sum from model
    @maxSum = keyframe.get 'maxSum'

    oldDataType = @dataType
    @dataType = keyframe.get 'dataType'

    # Show an error message if there are no elements
    if @getElementCount() is 0
      @clear()
      @showElementCountError()
      return
    else
      @hideElementCountError()

    # Redraw from scratch when data type has changed
    if @elements and not _.isEqual(@dataType, oldDataType)
      @fadeOutAndRedraw()
    else
      @updateAndDraw()

    return

  # Fades out existing chart and draws a new chart from scratch.
  fadeOutAndRedraw: ->
    element.fadeOut() for element in @elements
    utils.after @animationDuration / 2 + 15, =>
      @clear()
      @updateAndDraw()
    return

  updateAndDraw: ->
    # Sync display objects
    unless @elements
      update = false
    else
      update = true
    @syncElements()
    @syncRelations()

    # Update
    @updateElements()
    @updateRelations()

    # (Re-)draw
    @draw update
    return

  # Disposal
  # --------

  disposed: false

  dispose: ->
    return if @disposed
    clearTimeout @initLockingHandle
    $(window).off 'resize', @resize
    super

module.exports = Chart
