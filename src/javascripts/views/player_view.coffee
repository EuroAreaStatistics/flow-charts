'use strict'
_ = require 'lodash'
$ = require 'jquery'
Raphael = require 'raphael'
View = require 'views/view'
ContextboxView = require 'views/contextbox_view'
Chart = require 'display_objects/chart'
LegendView = require 'views/legend_view'
fullscreen = require 'lib/fullscreen'
scale = require 'lib/scale'
support = require 'lib/support'
template = require 'templates/player.hamlc'

# Constants
# ---------

PLAYER_CLASS_NAME = 'flow-viz-player'
CHART_CLASS_NAME = 'flow-viz-chart'

ENABLED = 'enabled'
DISABLED = 'disabled'
TOOLTIP_SELECTOR = '.tooltip'

class PlayerView extends View

  # Property declarations
  # ---------------------
  #
  # model: Presentation

  templateName: 'player'

  className: PLAYER_CLASS_NAME

  autoRender: true

  chart: null
  dots: null
  currentKeyframeIndex: 0

  events:
    'click .nav-left':  'moveToPreviousKeyframe'
    'click .nav-right': 'moveToNextKeyframe'
    'click .nav-play': 'togglePlay'
    'click .toggle-fullscreen': 'toggleFullscreen'
    'click .toggle-legend': 'toggleLegend'
    'mouseenter .nav-left.enabled, .nav-right.enabled, .toggle-legend, .toggle-fullscreen': 'showTooltip'
    'mouseleave .nav-left, .nav-right, .toggle-legend, .toggle-fullscreen': 'hideTooltip'

  initialize: (options) ->
    super
    @container = options.container

    @listenTo @model, 'keyframesLoaded', @keyframesLoadedHandler

    $(window).resize @resize
    return

  getTemplateFunction: ->
    template

  # Shortcuts
  # ---------

  getKeyframes: ->
    @model.get 'keyframes'

  getCurrentKeyframe: ->
    @getKeyframes()?.at @currentKeyframeIndex

  getNextKeyframe: ->
    @getKeyframes()?.at @currentKeyframeIndex + 1

  getPreviousKeyframe: ->
    @getKeyframes()?.at @currentKeyframeIndex - 1

  getKeyframe: (index) ->
    @getKeyframes().at index

  getNumKeyframes: ->
    @getKeyframes().length

  atFirstKeyframe: ->
    @currentKeyframeIndex < 1

  atLastKeyframe: ->
    @currentKeyframeIndex >= @getNumKeyframes() - 1

  shouldShowTitles: ->
    not /show_titles=0/.test(location.href)

  shouldAnimate: ->
    /animate=1/.test(location.href)

  # Event Handlers
  # --------------

  keyframesLoadedHandler: ->
    @currentKeyframeIndex = 0
    @initChart() if @getKeyframes().length > 0
    return

  resize: =>
    @renderLegend()
    return

  # Limit calls to resize
  @prototype.resize = _.debounce @prototype.resize, 300

  # Navigation

  documentKeydown: (event) =>
    switch event.keyCode
      when 37, 38
        @moveToPreviousKeyframe()
      when 39, 40, 32
        @moveToNextKeyframe()
      when 33, 36
        @moveToFirstKeyframe()
      when 34, 35
        @moveToLastKeyframe()
    return

  moveToFirstKeyframe: (event) ->
    event?.preventDefault()
    @currentKeyframeIndex = 0
    @update()
    return

  moveToLastKeyframe: (event) ->
    event?.preventDefault()
    @currentKeyframeIndex = @getNumKeyframes() - 1
    @update()
    return

  moveToNextKeyframe: (event) ->
    if event
      event.preventDefault()
    unless @atLastKeyframe()
      @currentKeyframeIndex++
      @update()
    return

  moveToPreviousKeyframe: (event) ->
    event.preventDefault() if event
    unless @atFirstKeyframe()
      @currentKeyframeIndex--
      @update()
    return

  # Auto-play

  togglePlay: (event) ->
    if event
      event.preventDefault()
    if @isPlaying()
      @stopPlay()
    else
      @startPlay()
    return

  startPlay: ->
    @moveToFirstKeyframe() if @atLastKeyframe()

    @playTimer = setInterval @playNext, 5000
    @$('> .footer .nav-play').addClass 'stop'
    return

  playNext: =>
    atLastKeyframe = @atLastKeyframe()
    if atLastKeyframe
      @stopPlay()
    else
      @moveToNextKeyframe()
    return

  stopPlay: ->
    clearInterval @playTimer
    delete @playTimer
    @$('> .footer .nav-play').removeClass 'stop'
    return

  isPlaying: ->
    @playTimer?

  # Legend

  toggleLegend: (event) ->
    event.preventDefault()
    legendView = @subview('legendAbout') or @subview('legend')
    legendView.toggle()
    return

  # Fullscreen

  toggleFullscreen: (event) ->
    event.preventDefault()
    if fullscreen.isFullScreen()
      fullscreen.exitFullscreen @el
    else
      fullscreen.requestFullscreen @el
    return

  # Rendering
  # ---------

  render: ->
    super

    @$chart = @$('.flow-viz-chart')

    unless @shouldShowTitles()
      @$('> .header .title').hide()

    @initAnimationControls()
    @renderContextboxView()

    # Observe document-wide key shortcuts
    $(document).keydown @documentKeydown

    # Append to the DOM before creating the chart
    @attach()

    @createChart()

    if @getKeyframes().length > 0
      @initChart()

    return

  getTemplateData: ->
    data = super
    data.chartClassName = CHART_CLASS_NAME
    data

  initAnimationControls: ->
    footer = @$('> .footer')
    playButton = footer.find '.nav-play'
    prevNextNavigation = footer.find '.nav-left, .nav-right'
    if @shouldAnimate()
      playButton.show()
      prevNextNavigation.hide()
    else
      playButton.hide()
      prevNextNavigation.show()
    return

  createChart: ->
    container = @$chart.get 0
    @chart = new Chart {container}
    @subview 'chart', @chart
    return

  renderLegend: ->
    @removeSubview 'legend'
    keyframe = @getCurrentKeyframe()
    return unless keyframe and keyframe.get('elements').length

    overlay = $(window).width() < 650
    view = new LegendView {
      model: @getCurrentKeyframe()
      container: @el
      overlay
    }
    @subview 'legend', view
    return

  renderContextboxView: ->
    @subview 'contextbox', new ContextboxView {
      @model
      container: @el
    }
    return

  # Chart initialization and updating
  # ---------------------------------

  initChart: ->
    # Check if the chart was created (weird IE6 timing bug)
    return unless @chart
    @initNumKeyframes()
    @initDots()
    @update()
    @startPlay() if @shouldAnimate()
    return

  update: ->
    @chart.update {
      keyframe: @getCurrentKeyframe()
    }
    @renderLegend()
    @updateControls()
    return

  initNumKeyframes: ->
    @$('.num-keyframes').text @getNumKeyframes()
    return

  updateControls: ->
    keyframe = @getCurrentKeyframe()
    date = keyframe.get 'date'

    @updateHeader()

    # Date inside the chart
    @$('.current-date').text date

    @updateFooter()
    return

  updateHeader: ->
    header = @$('> .header')

    keyframe = @getCurrentKeyframe()
    title = keyframe.get 'title'
    subtitle = keyframe.getSubtitle()
    date = keyframe.get 'date'

    header.find('.title').text title
    header.find('.relation').text subtitle
    return

  updateFooter: ->
    footer = @$('> .footer')

    keyframe = @getCurrentKeyframe()

    footer.find('.current-index').text @currentKeyframeIndex + 1
    footer.find('.title').text keyframe.getDisplayTitle()

    @updateNavButtons()
    @highlightSelectedDot()
    return

  updateNavButtons: ->
    footer = @$('> .footer')
    navLeft = footer.find '.nav-left'
    navRight = footer.find '.nav-right'

    if @atFirstKeyframe()
      navLeft.addClass(DISABLED).removeClass(ENABLED)
    else
      navLeft.addClass(ENABLED).removeClass(DISABLED)
      @updateTooltip navLeft.find(TOOLTIP_SELECTOR), @getPreviousKeyframe()

    if @atLastKeyframe()
      navRight.addClass(DISABLED).removeClass(ENABLED)
    else
      navRight.addClass(ENABLED).removeClass(DISABLED)
      @updateTooltip navRight.find(TOOLTIP_SELECTOR), @getNextKeyframe()
    return

  updateTooltip: ($tooltip, keyframe) ->
    nbsp = '\u00A0'
    unbreakText = (text) -> text.replace(/\s+/g, nbsp)
    title = keyframe.get('title') + ' '
    subtitle = keyframe.getSubtitle() + ' '

    $tooltip.find('.main-title').text unbreakText(title)
    $tooltip.find('.sub-title').text  unbreakText(subtitle)
    return

  # We can’t use CSS :hover for this because we need to exclude Mobile Safari
  showTooltip: (event) ->
    # Don’t show the tooltip if it would prevent the click event
    return unless support.mouseover
    $(event.currentTarget).find(TOOLTIP_SELECTOR).show()
    return

  hideTooltip: (event) ->
    # Don’t show the tooltip if it would prevent the click event
    return unless support.mouseover
    $(event.currentTarget).find(TOOLTIP_SELECTOR).hide()
    return

  # Dot navigation
  # --------------

  dotSettings =
    activeRadius: 5.5
    inactiveRadius: 4
    activeColor: '#86dcff'
    inactiveColor: '#fff'
    spacing: 13

  initDots: ->
    @dots = []
    return unless Raphael.type

    dots = @$('.dots').get(0)
    numKeyframes = @getNumKeyframes()

    @dotPaper = Raphael dots, dotSettings.spacing * numKeyframes, 20
    for index in [0...numKeyframes]
      do (index) =>
        dot = @dotPaper
          .circle(
            dotSettings.spacing / 2 + (index * dotSettings.spacing),
            10,
            dotSettings.inactiveRadius
          )
          .attr(fill: dotSettings.inactiveColor, 'stroke-opacity': 0)
          .data('index', index)
          .hover(
            => @dotMouseIn dot
            => @dotMouseOut dot
          )
          .click(
            => @dotClick dot
          )
        @dots.push dot
        return
    return

  highlightSelectedDot: ->
    for dot, index in @dots
      if index is @currentKeyframeIndex
        dot.attr
          r: dotSettings.activeRadius
          fill: dotSettings.activeColor
      else
        dot.attr
          r: dotSettings.inactiveRadius
          fill: dotSettings.inactiveColor
    return

  dotMouseIn: (dot) ->
    # Don’t change the DOM if it would prevent the click event
    return unless support.mouseover
    dot.attr r: dotSettings.activeRadius
    @showDotTooltip dot
    return

  dotMouseOut: (dot) ->
    # Don’t change the DOM if it would prevent the click event
    return unless support.mouseover
    dotIndex = dot.data 'index'
    active = dotIndex is @currentKeyframeIndex
    if active
      dot.attr r: dotSettings.activeRadius
    else
      dot.attr r: dotSettings.inactiveRadius
    @hideDotTooltip()
    return

  dotClick: (dot) ->
    dotIndex = dot.data 'index'
    @currentKeyframeIndex = dotIndex
    @update()
    return

  showDotTooltip: (dot) ->
    dotIndex = dot.data 'index'
    keyframe = @getKeyframe(dotIndex)

    $tooltip = @$(".dots #{TOOLTIP_SELECTOR}")
    @updateTooltip $tooltip, keyframe
    dotOffset = dotSettings.spacing / 2 + (dotIndex * dotSettings.spacing)
    tooltipWidth = $tooltip.outerWidth()
    left = dotOffset - tooltipWidth / 2
    $tooltip.css
      display: 'block'
      left: "#{left}px"
    return

  hideDotTooltip: ->
    @$(".dots #{TOOLTIP_SELECTOR}").hide()
    return

  # Disposal
  # --------

  dispose: ->
    return if @disposed
    @stopPlay()
    @chart.dispose()
    $(document).off 'keydown', @documentKeydown
    $(window).off 'resize', @resize
    super

module.exports = PlayerView
