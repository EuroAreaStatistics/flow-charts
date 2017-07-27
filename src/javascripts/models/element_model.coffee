'use strict'
_ = require 'lodash'
IndicatorModel = require 'models/indicator_model'

# This class creates mere value objects that store the data
# in a usable format for the Element display object

class ElementModel

  # Property declarations
  # ---------------------
  #
  # id: String
  # title: String
  # dataType: Object
  # date: String/Number
  # sum: String
  # sumIn: Number
  # sumOut: Number
  # incoming: Object
  # outgoing: Object
  # missingRelations: Object
  # noIncoming: Array
  # noOutgoing: Array
  # indicators: Array.<IndicatorModel>

  constructor: (options) ->
    # Mandatory properties
    {@id, @title, @dataType, @date, @sumIn, @sumOut} = options

    # List properties
    @incoming = options.incoming or {}
    @outgoing = options.outgoing or {}
    @missingRelations = options.missingRelations or {}
    @noIncoming = options.noIncoming or []
    @noOutgoing = options.noOutgoing or []

    # Calculate total sum
    @sum = @sumOut + @sumIn

    # Convert indicator objects to IndicatorModel instances
    @indicators = _.map options.indicators, (indicatorData, index) ->
      indicatorType = options.indicatorTypes[index]
      # Merge type metadata and data
      properties = _.extend {}, indicatorType, indicatorData
      new IndicatorModel properties

module.exports = ElementModel
