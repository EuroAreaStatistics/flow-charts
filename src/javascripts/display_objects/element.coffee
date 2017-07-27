'use strict'
_ = require 'lodash'
DisplayObject = require 'display_objects/display_object'
Magnet = require 'display_objects/magnet'
Indicators = require 'display_objects/indicators'
utils = require 'lib/utils'

# Shortcuts
# ---------

LEFT = 'left'
RIGHT = 'right'

class Element extends DisplayObject

  # Property Declarations
  # ---------------------
  #
  # id: String
  #
  # model: ElementModel
  #
  # relationsOut: Array
  #   Outgoing relations
  # relationsIn: Array
  #   Incoming relations
  #
  # total: Number
  #   Volume as a sum of the relations to
  #   the countries in the current selection
  # totalIn: Number
  #   Incoming volume
  # totalOut: Number
  #   Outgoing volume
  #
  # Children:
  #
  # magnet: Magnet
  # indicators: Indicators
  #
  # Drawing variables which are passed in:
  #
  # paper: Raphael.Paper
  # $container: jQuery
  # animationDuration: Number
  # chartFormat: String
  # chartDrawn: Boolean
  # chartRadius: Number
  # elementCount: Number
  #   Number of elements in the chart
  # elementIdsChanged: Boolean

  DRAW_OPTIONS:
    ('paper $container animationDuration chartFormat chartDrawn ' +
    'chartRadius elementCount elementIdsChanged').split(' ')

  constructor: (@model) ->
    super

    # Set up deprecation warning for properties that moved to the model

    throwPropertyError = (property) ->
      console.log(
        "Element##{property} deprecated. Use the .model.#{property} instead"
      )
      @model[property]

    deprecateProperty = (object, property) ->
      Object.defineProperty(
        object, property,
        get: _.partial(throwPropertyError, property)
      )
      return

    deprecatedProperties = [
      'name', 'type', 'unit', 'typeData', 'sumIn', 'sumOut', 'date'
    ]
    if Object.defineProperty
      deprecatedProperties.forEach (property) =>
        deprecateProperty this, property

    {@id} = @model

    # Create relations
    @relationsIn = []
    @relationsOut = []

    @resetTotalVolume()

    # Create children
    @createMagnet()
    @createIndicators()

  # Updating
  # --------

  update: (@model, @configuration) ->
    @magnet.update @model, @configuration
    @indicators.update @model.indicators, @configuration
    return

  # Volume helpers
  # --------------

  # TODO: Move to model?
  # Ratio between outgoing and total volume
  getRate: ->
    return 0 if @model.sum is 0
    @model.sumOut / @model.sum

  resetTotalVolume: ->
    @totalIn = 0
    @totalOut = 0
    @total = 0
    return

  # TODO: Move to model?
  valueIsMissing: (part) ->
    m = @model
    (part is 'outgoing' and m.noOutgoing.length > 0 and m.sumOut is 0) or
    (part is 'incoming' and m.noIncoming.length > 0 and m.sumIn is 0)

  # Magnet
  # ------

  createMagnet: ->
    magnet = new Magnet this
    @magnet = magnet
    @addChild magnet
    magnet

  # Indicators
  # ----------

  createIndicators: ->
    @indicators = new Indicators this
    @addChild @indicators
    return

  # Relations
  # ---------

  # Returns a new array with all relations
  getAllRelations: ->
    @relationsIn.concat @relationsOut

  # Adding relations
  # ----------------

  addRelationIn: (relation) ->
    @relationsIn.push relation
    # Keep the array sorted
    @relationsIn.sort utils.relationSorter
    @addRelation relation
    return

  addRelationOut: (relation) ->
    @relationsOut.push relation
    # Keep the array sorted
    @relationsOut.sort utils.relationSorter
    @addRelation relation
    return

  # Private method for adding a relation and increasing the volume
  addRelation: (relation) ->
    # Update total volume
    @totalOut += relation.value
    @total += relation.value
    return

  # Removing relations
  # ------------------

  removeRelationIn: (relation) ->
    @relationsIn = _.without @relationsIn, relation
    @removeRelation relation
    return

  removeRelationOut: (relation) ->
    @relationsOut = _.without @relationsOut, relation
    @removeRelation relation
    return

  # Private method for removing a relation and decreasing the volume
  removeRelation: (relation) ->
    # Update total volume
    @totalIn -= relation.value
    @total -= relation.value
    return

  # Removes all relations, empties the lists, resets the volumes
  removeRelations: ->
    @relationsOut = []
    @relationsIn = []
    @resetTotalVolume()
    return

  # Drawing
  # -------

  draw: (options) ->
    @saveDrawOptions options

    # Magnet
    @magnet.draw options

    # Relations
    if @elementCount is 2
      @drawOneToOneRelations options
    else
      @drawNormalRelations options

    # Draw Indicators
    options.degDiff = Math.abs(
      @magnet.degdeg - options.previousElement.magnet.degdeg
    )
    @indicators.draw options

    @drawn = true
    return

  # Draw relations
  # --------------

  # Returns the percent position of a relation in all sorted
  # incoming or outgoing relations, measured by the relation value
  # TODO: Use positionIn / positionOut here?
  getRelationPosition: (relation) ->
    total = if relation.from is this then @model.sumOut else @model.sumIn
    @getRelationSum(relation) / total

  # Returns the sum of the relations before the given relation
  getRelationSum: (relation) ->
    sum = 0
    relations = if relation.from is this then @relationsOut else @relationsIn
    for otherRelation in relations
      if otherRelation is relation
        break
      else
        sum += otherRelation.value
    sum

  drawNormalRelations: (options) ->
    @forOutgoingRelations (relation) ->
      relation.draw options
    return

  drawOneToOneRelations: (options) ->
    side = if @magnet.degdeg is 180 then LEFT else RIGHT
    drawInverseFrom = side is LEFT
    drawInverseTo = side is RIGHT
    @forOutgoingRelations (relation) ->
      relation.draw options, drawInverseFrom, drawInverseTo
      return
    return

  # Helper for iterating all visible outgoing relations with a target element
  forOutgoingRelations: (callback) ->
    for relation in @relationsOut when relation.visible and relation.to
      callback relation
    return

  # Fade out before disposal
  fadeOut: ->
    @magnet.fadeOut()
    if @elementCount <= 8 and not @elementIdsChanged
      @indicators.fade false, @animationDuration / 2
    @forOutgoingRelations (relation) ->
      relation.fadeOut()
      return
    return

  # Disposal
  # --------

  dispose: ->
    return if @disposed

    # Dispose relations. Magnet and indicators are disposed automatically
    # since they are children.
    relation.dispose() for relation in @relationsOut.concat()
    relation.dispose() for relation in @relationsIn.concat()

    super

module.exports = Element
