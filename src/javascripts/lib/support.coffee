'use strict'

# Feature detection
# -----------------

support = {}

# Do not render rollovers in Mobile Safari because changing the DOM in
# a mouseenter handler will prevent the click event from firing. See:
# http://sitr.us/2011/07/28/how-mobile-safari-emulates-mouse-events.html
# This is inconsistent across touch devices, so this is not a general
# touch device / touch event detection.
support.mouseover = do ->
  ua = navigator.userAgent
  not (
    /(^|\s)AppleWebKit\/[^\s]+(\s|$)/.test(ua) and
    /(^|\s)Mobile\/[^\s]+(\s|$)/.test(ua)
  )

Object.freeze? support

module.exports = support
