'use strict'
_ = require 'lodash'
Backbone = require 'backbone'
utils = require 'lib/utils'
ElementModel = require 'models/element_model'

class Keyframe extends Backbone.Model

  # Attributes
  # ----------
  #
  # dataType: Object
  # indicatorTypes: Array.<Object>
  # date: String/Number
  # title: String
  # locking: String or Array
  # elements: Array.<ElementModel>
  # indicatorBounds: Array.<Array>
  # maxSum: Number
  # maxLabelsVisible: Number

  # Keyframe title
  # --------------

  # Returns the title if specified, otherwise the data type and the date
  # e.g. “Trade 2010”
  getDisplayTitle: ->
    @get('title') or @getSubtitle()

  # Returns a title derived from the data type and the date
  # e.g. “Trade 2010”
  getSubtitle: ->
    @template(
      ['chart', 'keyframe_subtitle'],
      {
        dataType: @t('dataType', @get('dataType').type)
        date: @get('date')
      }
    )

  # Configuration shortcuts
  # -----------------------

  t: ->
    @get('configuration').i18n.t arguments...

  template: ->
    @get('configuration').i18n.template arguments...

  # Serialization / Deserialization
  # -------------------------------

  parse: (data) ->
    data = _.clone data, true
    data.maxLabelsVisible ?= 8

    {date, dataType, indicatorTypes, configuration} = data

    # Add the representation to the indicator types
    indicatorTypes = _.map data.indicatorTypes, (indicatorType) =>
      _.extend {}, indicatorType, {
        representation: configuration.unit(indicatorType.unit).representation
      }
    data.indicatorTypes = indicatorTypes

    # Transform raw objects into ElementModel instances
    data.elements = _.map data.elements, (elementData) ->
      properties = _.extend(
        # Pass some keyframe properties to the element models
        {date, dataType, indicatorTypes}
        elementData
      )
      new ElementModel properties

    # Add indicator scaling (elements[i].indicators[j].scale)
    @scaleIndicators data

    # Add relation positions
    @addRelationPositions data

    data

  # Add the scale to the absolute indicators
  scaleIndicators: (data) ->
    _.chain(data.indicatorTypes)
      # Absolute indicators only
      .filter (indicatorType) =>
        indicatorType.representation is 'absolute'
      # Add the index
      .map (indicatorType, index) ->
        _.extend {}, indicatorType, {index}
      .forEach (indicatorType) ->
        index = indicatorType.index
        # Aggregate all indicators for this type
        for element in data.elements
          indicator = element.indicators[index]
          # Shared max value
          maxValue = _.max data.indicatorBounds[index], Math.abs
          # Add scale
          indicator.scale = Math.abs(indicator.value) / maxValue
        return
      .value()
    return

  # Adds positionOut and positionIn to outgoing relations,
  # positionIn to incoming relations. Replaces the relation values with
  # objects containing value, positionOut and positionIn.
  addRelationPositions: (data) ->
    {elements} = data

    # Gather all incoming relations and add `positionIn` to them
    # { $toId: { $fromId: { value, positionIn }, … }, … }
    allIncomingById = {}
    # Start with the natural incoming relations
    for element in elements
      allIncomingById[element.id] = _.mapValues(
        element.incoming, (value) -> {value}
      )
    for element in elements
      # Create incoming from outgoing relations
      for toId, value of element.outgoing
        allIncomingById[toId] ?= {}
        allIncomingById[toId][element.id] = {value}
    # Calculate `positionIn`
    for toId, incoming of allIncomingById
      # Sorted array of incoming relations for an element
      # [ { id, value }, … ]
      incomingArray = _.map incoming, (values, id) ->
        _.extend {id}, values
      incomingArray.sort utils.relationSorter
      {sumIn} = _.find elements, id: toId
      relationSum = 0
      for relation in incomingArray
        # Calculate and add `positionIn`
        incoming[relation.id].positionIn = relationSum / sumIn
        relationSum += relation.value

    # Add `positionIn` for incoming relations
    for element in elements
      # Replace incoming with new object of objects
      element.incoming = _.mapValues element.incoming, (value, id) ->
        # Use calculated `positionIn`
        allIncomingById[element.id][id]

    # Calculate `positionOut` and add `positionIn` for outgoing relations
    for element in elements
      # [ { id, value, positionOut, positionIn }, … ]
      outgoingArray = _.map element.outgoing, (value, id) -> {id, value}
      outgoingArray.sort utils.relationSorter
      relationSum = 0
      for relation in outgoingArray
        # Calculate `positionOut`
        relation.positionOut = relationSum / element.sumOut
        # Use calculated `positionIn`
        relation.positionIn =
          allIncomingById[relation.id][element.id].positionIn
        relationSum += relation.value
      # { $toId: { value, positionOut, positionIn }, … }
      reducer = (result, relation) ->
        result[relation.id] = _.omit relation, 'id'
        result
      element.outgoing = _.reduce outgoingArray, reducer, {}

    return

  # Indicator helpers
  # -----------------

  getIndicatorMaxValue: (indicatorType) ->
    indicatorTypes = @get 'indicatorTypes'
    index = _.indexOf indicatorTypes, indicatorType
    return null unless indicatorTypes.length > index

    bounds = @get('indicatorBounds')[index]
    maxValue = _.max bounds, Math.abs

    maxValue

module.exports = Keyframe
