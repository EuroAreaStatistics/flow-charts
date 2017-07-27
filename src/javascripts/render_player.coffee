'use strict'

Presentation = require 'models/presentation'
PlayerView = require 'views/player_view'

# Creates a chart player at the given container element.
# Expects a selector for jQuery and a presentation data object:
# { keyframes: Array, colors: Object, locale: Object, typeData: Object }
# Returns an Object { model: Backbone.Model, view: Backbone.View }
renderPlayer = (container, presentationData) ->
  model = new Presentation presentationData, parse: true
  view = new PlayerView { model, container }
  { model, view }

module.exports = renderPlayer
