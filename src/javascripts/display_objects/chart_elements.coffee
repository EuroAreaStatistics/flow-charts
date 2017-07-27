'use strict'
_ = require 'lodash'
Element = require 'display_objects/element'

# These methods are mixed into Chart
# ----------------------------------

ChartElements =

  # Helpers
  # -------

  # Get the element models from the keyframe
  elementModels: ->
    @keyframe.get 'elements'

  getElementCount: ->
    @keyframe.get('elements').length

  # Syncs elements with keyframe
  # ----------------------------

  syncElements: ->
    unless @elements
      @elements = []
      @elementsById = {}

    elementModels = @elementModels()
    oldElementIds = _.pluck(@elements, 'id').join()
    newElementIds = _.pluck(elementModels, 'id').join()

    keepElements = {}

    for elementModel in elementModels
      {id} = elementModel
      keepElements[id] = true
      element = @elementsById[id]
      # Add new elements
      @addElement elementModel unless element

    # Remove old elements
    for element in @elements
      unless element.id of keepElements
        @removeElement element

    @sortElements()

    # Update elementIdsChanged flag
    @elementIdsChanged = newElementIds isnt oldElementIds
    return

  # Updates all existing elements from their models
  updateElements: ->
    for elementModel in @elementModels()
      element = @elementsById[elementModel.id]
      element.update elementModel, @configuration
    return

  # Sort elements in the order they appear in the keyframe
  sortElements: ->
    @elements = _.map @elementModels(), (elementModel) =>
      @elementsById[elementModel.id]
    return

  # Adds an element to the chart
  # ----------------------------

  addElement: (elementModel) ->
    element = new Element elementModel
    @addMagnetHandlers element.magnet
    @elementsById[elementModel.id] = element
    @elements.push element
    element

  # Removal
  # -------

  # Removes an element from the chart
  removeElement: (element) ->
    element.dispose()
    delete @elementsById[element.id]
    @elements = _.without @elements, element
    return

  # Removes all elements from the chart
  removeElements: ->
    if @elements
      for element in @elements
        element.dispose()
    delete @elements
    delete @elementsById
    return

module.exports = ChartElements
