'use strict'
_ = require 'lodash'

# This class creates mere value objects that store data
# in a usable format for the Indicator display object

class IndicatorModel

  # Property declarations
  # ---------------------
  #
  # type: String
  # unit: Number
  # representation: String
  #   'absolute' or 'proportional'
  # value: String
  # tendency: Number
  #   null: no tendency
  #   2: heavily increasing
  #   1: increasing
  #   0: steady
  #   -1: decreasing
  #   -2: heavily decreasing
  # tendencyPercent: Number

  # The percent scale of the value relative to
  # the maximum value in the whole chart
  scale: 1

  constructor: (options) ->
    {@type, @unit, @representation, @value,
      @tendency, @tendencyPercent, @missing} = options

module.exports = IndicatorModel
