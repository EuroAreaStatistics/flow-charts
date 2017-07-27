'use strict'
Backbone = require 'backbone'

module.exports = {
  subscribe: Backbone.Events.on
  unsubscribe: Backbone.Events.off
  publish: Backbone.Events.trigger
}
