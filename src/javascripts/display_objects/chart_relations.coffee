'use strict'
_ = require 'lodash'
Relation = require 'display_objects/relation'
utils = require 'lib/utils'

# Constants
# ---------

# Show the x biggest relations of the y biggest countries
BIGGEST_COUNTRIES = 5
BIGGEST_COUNTRIES_RELATIONS = 4
# Show the z next biggest relations
BIGGEST_RELATIONS = 5

# These methods are mixed into Chart
# ----------------------------------

ChartRelations =

  # Synchronize relations with keyframe
  # -----------------------------------

  syncRelations: ->
    @syncOutgoingRelations()
    @syncIncomingRelations()

    # Visibility
    @filterRelations()
    return

  syncOutgoingRelations: ->
    keepRelations = {}

    for elementModel in @elementModels()
      fromId = elementModel.id
      from = @elementsById[fromId]
      for toId of elementModel.outgoing
        keepRelations["#{fromId}>#{toId}"] = true
        relation = _.find from.relationsOut, {toId}
        # Create new
        unless relation
          to = @elementsById[toId] or null
          @createRelation fromId, from, toId, to

    # Remove old
    for element in @elements
      for relation in element.relationsOut
        unless relation.id of keepRelations
          relation.dispose()

    return

  syncIncomingRelations: ->
    # Create the incoming relations from scratch for simplicity
    @removeIncomingRelations()
    @createIncomingRelations()
    return

  # Creating relations
  # ------------------

  createOutgoingRelations: (elementModels) ->
    for elementModel in elementModels
      {outgoing} = elementModel
      continue unless outgoing
      fromId = elementModel.id
      from = @elementsById[fromId]
      for toId, value of outgoing when value > 0
        # to element might be missing
        to = @elementsById[toId] or null
        @createRelation fromId, from, toId, to
    return

  # Creates incoming relations from countries that are not in the chart
  # (i.e. relations without a `from` element).
  # Used in charts with 1-2 elements.
  createIncomingRelations: ->
    for elementModel in @elementModels()
      {incoming} = elementModel
      continue unless incoming
      toId = elementModel.id
      to = @elementsById[toId]
      for fromId, value of incoming when value > 0
        from = @elementsById[fromId]
        # Skip if the `from` element is in the chart
        # (an outgoing relation already exists)
        @createRelation fromId, null, toId, to unless from
    return

  # Creates a new relation and connects it to its elements
  createRelation: (fromId, from, toId, to) ->
    relation = new Relation {fromId, from, toId, to}
    @connectRelation relation
    @addRelationHandlers relation
    relation

  # Removing relations
  # ------------------

  # Disposes all incoming relations with an empty `from`.
  removeIncomingRelations: ->
    @getIncomingRelations().forEach (relation) ->
      relation.dispose()
    return

  # Connecting relations with their elements
  # ----------------------------------------

  connectRelation: (relation) ->
    {from, to} = relation
    from.addRelationOut relation if from
    to.addRelationIn relation if to
    return

  disconnectRelation: (relation) ->
    {from, to} = relation
    from.removeRelationOut relation if from
    to.removeRelationIn relation if to
    return

  # Updating relations
  # ------------------

  updateRelations: ->
    @updateOutgoingRelations()
    # Update the incoming relations:
    # Nothing to do here, `syncIncomingRelations` recreates them from scratch
    return

  updateOutgoingRelations: ->
    elementModels = @elementModels()
    for from in @elements
      fromId = from.id
      elementModel = _.find elementModels, id: fromId
      for relation in from.relationsOut
        toId = relation.toId
        to = @elementsById[toId] or null
        oldTo = relation.to
        relationModel = elementModel.outgoing[toId]
        missingRelations = elementModel.missingRelations[toId] or null

        relation.update {
          @configuration,
          to
          value: relationModel.value
          positionOut: relationModel.positionOut
          positionIn: relationModel.positionIn
          missingRelations
        }

        # `to` might have changed. Reconnect the relation with the target.
        if to isnt oldTo
          @disconnectRelation relation
          @connectRelation relation

        # Hide relations to a country that isn’t in the chart any longer
        relation.hide() unless to
    return

  # Relation visibility: Show only the most important relations
  # -----------------------------------------------------------

  filterRelations: ->
    allRelations = @getAllRelations()

    # Show all relations if less than 9 countries
    # TODO: Disabled for now
    if true or @elements.length < 9
      for relation in allRelations
        relation.show()
      return

    # Gather visible relations
    visibleRelations = {}

    # Sort a copy of the elements
    elements = @elements.concat().sort utils.elementsSorter
    # Show the x biggest relations of the y biggest countries
    for element in elements[0...BIGGEST_COUNTRIES]
      relationsOut = element.relationsOut[0...BIGGEST_COUNTRIES_RELATIONS]
      for relation in relationsOut
        visibleRelations[relation.id] = true

    # Sort relations by their value (descending)
    allRelations.sort utils.relationSorter
    # Show the z next biggest relations
    found = 0
    for relation in allRelations
      unless relation.id of visibleRelations
        visibleRelations[relation.id] = true
        found++
        break if found is BIGGEST_RELATIONS

    # Apply visibility
    for relation in allRelations
      if relation.id of visibleRelations
        relation.show()
      else
        relation.hide()

    return

  # Relation getters
  # ----------------

  # Return an array with all outgoing relations of all elements
  getAllRelations: ->
    allRelations = []
    for element in @elements
      for relation in element.relationsOut
        allRelations.push relation
    allRelations

  getIncomingRelations: ->
    reducer = (result, element) ->
      incoming = _.filter element.relationsIn, (relation) ->
        relation.from is null
      result.concat incoming
    _.reduce @elements, reducer, []

  # Find an outgoing relation by from and to IDs
  getRelation: (fromId, toId) ->
    for element in @elements
      for relation in element.relationsOut
        if relation.fromId is fromId and relation.toId is toId
          return relation
    false

module.exports = ChartRelations
