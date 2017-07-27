'use strict'
_ = require 'lodash'
Backbone = require 'backbone'
I18n = require 'lib/i18n'
Keyframes = require 'models/keyframes'

class Presentation extends Backbone.Model

  # Attributes
  # ----------
  #
  # keyframes: Keyframes
  # configuration: { i18n: Function, colors: Object, color: Function,
  #   typeData: Object, unit: Function, decimals: Number }

  # Keyframes handling
  # ------------------

  getKeyframes:->
    @get 'keyframes'

  # Create a new keyframes collection from the given keyframes array.
  loadKeyframes: (keyframes) ->
    keyframes = @parseKeyframes keyframes
    @set {keyframes}
    @triggerKeyframesLoaded()
    return

  # Trigger a keyframesLoaded event so views can update
  triggerKeyframesLoaded: ->
    @trigger 'keyframesLoaded', @getKeyframes()
    return

  # Deserialization
  # ---------------

  parse: (data) ->
    data = _.clone data

    # Create a configuration
    configuration = @configuration data
    data.configuration = configuration

    data.keyframes = @parseKeyframes data.keyframes, configuration

    data

  # Creates a keyframes collection from a keyframes array.
  # Pass configuration to the individual keyframe models.
  parseKeyframes: (keyframes, configuration = @get('configuration')) ->
    keyframes = keyframes.map (keyframe) ->
      _.extend {}, keyframe, {configuration}
    new Keyframes keyframes, parse: true

  # Configuration
  # -------------

  # Creates a configuration object
  # Returns { i18n: Function, colors: Object, color: Function,
  # typeData: Object, unit: Function, decimals: Number }
  configuration: (data) ->
    {
      i18n: new I18n(data.locale)
      colors: data.colors
      # Returns a color from the color configuration tree
      color: (ids...) ->
        if ids.length is 0 or not _.every(ids)
          throw new TypeError "invalid color: #{ids}"
        tree = data.colors
        for id in ids
          tree = tree[id]
        console.error 'color not found', ids unless tree
        tree
      typeData: data.typeData
      # Returns the unit type configuration for a given unit id.
      unit: (id) ->
        throw new TypeError "invalid unit: #{id}" unless id
        unit = data.typeData.units[id]
        console.error 'unit not found', unit unless unit
        unit
      decimals: data.decimals ? 2
      }

  # Attribute getters
  # -----------------

  unit: (id) =>
    @get('configuration').unit id

  color: =>
    @get('configuration').color arguments...

module.exports = Presentation
