'use strict'

# Wire Backbone and jQuery
Backbone = require 'backbone'
jQuery = require 'jquery'
Backbone.$ = jQuery

renderPlayer = require './render_player'

# Expose globally
window.FlowViz or= {}
window.FlowViz.renderPlayer = renderPlayer
