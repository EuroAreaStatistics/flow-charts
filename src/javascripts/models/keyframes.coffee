'use strict'
_ = require 'lodash'
Backbone = require 'backbone'
Keyframe = require 'models/keyframe'

class Keyframes extends Backbone.Collection

  model: Keyframe

module.exports = Keyframes
