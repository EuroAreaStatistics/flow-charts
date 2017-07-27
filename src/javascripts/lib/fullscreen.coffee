# Fullscreen cross-browser library
# See https://github.com/sindresorhus/screenfull.js/blob/gh-pages/src/screenfull.js

'use strict'

doc = document

fullscreen =

  requestFullscreen: (el) ->
    if el.requestFullscreen
      el.requestFullscreen()
    else if el.mozRequestFullScreen
      el.mozRequestFullScreen()
    else if el.webkitRequestFullscreen
      el.webkitRequestFullscreen()
    else if el.webkitRequestFullScreen
      el.webkitRequestFullScreen()
    else if el.msRequestFullscreen
      el.msRequestFullscreen()
    else
      # Fall back to an old-school popup window
      options = 'fullscreen=yes,menubar=no,location=no,toolbar=no,status=no'
      window.open location.href, '_blank', options
    return

  exitFullscreen: ->
    if doc.exitFullscreen
      doc.exitFullscreen()
    else if doc.mozCancelFullScreen
      doc.mozCancelFullScreen()
    else if doc.webkitExitFullscreen
      doc.webkitExitFullscreen()
    else if doc.webkitCancelFullScreen
      doc.webkitCancelFullScreen()
    else if doc.msExitFullscreen
      doc.msExitFullscreen()
    return

  isFullScreen: ->
    Boolean(
      doc.fullscreenElement or
      doc.mozFullScreenElement or
      doc.webkitFullscreenElement or
      doc.webkitCurrentFullScreenElement or
      doc.msFullscreenElement
    )

  toggleFullscreen: (el) ->
    if @isFullScreen()
      @exitFullscreen()
    else
      @requestFullscreen el
    return

module.exports = fullscreen
