# View adapted from Chaplin 0.9 (MIT-licensed)
# https://github.com/chaplinjs/chaplin/blob/0.9.0/src/chaplin/views/view.coffee

'use strict'
_ = require 'lodash'
$ = require 'jquery'
Backbone = require 'backbone'
utils = require 'lib/utils'
EventBroker = require 'lib/event_broker'

class View extends Backbone.View

  # Mixin an EventBroker.
  _.extend @prototype, EventBroker

  # Automatic rendering
  # -------------------

  # Flag whether to render the view automatically on initialization.
  # As an alternative you might pass a `render` option to the constructor.
  autoRender: false

  # Flag whether to attach the view automatically on render.
  autoAttach: true

  # Automatic inserting into DOM
  # ----------------------------

  # View container element.
  # Set this property in a derived class to specify the container element.
  # Normally this is a selector string but it might also be an element or
  # jQuery object.
  # The view is automatically inserted into the container when it’s rendered.
  # As an alternative you might pass a `container` option to the constructor.
  container: null

  # Method which is used for adding the view to the DOM
  # Like jQuery’s `html`, `prepend`, `append`, `after`, `before` etc.
  containerMethod: 'append'

  # Subviews
  # --------

  # List of subviews.
  subviews: null
  subviewsByName: null

  # State
  # -----

  # A view is `stale` when it has been previously composed by the last
  # route but has not yet been composed by the current route.
  stale: false

  constructor: (options) ->
    # Copy some options to instance properties.
    if options
      _.extend this, _.pick options, [
        'autoAttach', 'autoRender', 'container', 'containerMethod', 'region'
      ]

    # Wrap `render` so `attach` is called afterwards.
    # Enclose the original function.
    render = @render
    # Create the wrapper method.
    @render = =>
      # Stop if the instance was already disposed.
      return false if @disposed
      # Call the original method.
      render.apply this, arguments
      # Attach to DOM.
      @attach arguments... if @autoAttach
      # Return the view.
      this

    # Initialize subviews collections.
    @subviews = []
    @subviewsByName = {}

    # Call Backbone’s constructor.
    super

    # Listen for disposal of the model or collection.
    # If the model is disposed, automatically dispose the associated view.
    @listenTo @model, 'dispose', @dispose if @model
    if @collection
      @listenTo @collection, 'dispose', (subject) =>
        @dispose() if not subject or subject is @collection

    # Render automatically if set by options or instance property.
    @render() if @autoRender

  # Subviews
  # --------

  # Getting or adding a subview.
  subview: (name, view) ->
    if name and view
      # Add the subview, ensure it’s unique.
      @removeSubview name
      @subviews.push view
      @subviewsByName[name] = view
      view
    else if name
      # Get and return the subview by the given name.
      @subviewsByName[name]

  # Removing a subview.
  removeSubview: (nameOrView) ->
    return unless nameOrView
    subviews = @subviews
    byName = @subviewsByName

    if typeof nameOrView is 'string'
      # Name given, search for a subview by name.
      name = nameOrView
      view = byName[name]
    else
      # View instance given, search for the corresponding name.
      view = nameOrView
      for otherName, otherView of byName
        if view is otherView
          name = otherName
          break

    # Break if no view and name were found.
    return unless name and view and view.dispose

    # Dispose the view.
    view.dispose()

    # Remove the subview from the lists.
    index = _.indexOf subviews, view
    subviews.splice index, 1 if index isnt -1
    delete byName[name]

  # Rendering
  # ---------

  # Get the model/collection data for the templating function
  # Uses optimized Chaplin serialization if available.
  getTemplateData: ->
    templateData = if @model
      @model.toJSON()
    else if @collection
      {items: @collection.toJSON(), length: @collection.length}
    else
      {}
    # Add view helper methods
    _.extend templateData, {
      '_': _
      @t
      @template
    }

  # Returns the compiled template function.
  getTemplateFunction: ->
    throw new Error 'View#getTemplateFunction must be overridden'

  # Main render function.
  # This method is bound to the instance in the constructor (see above)
  render: ->
    # Do not render if the object was disposed.
    return false if @disposed

    templateFunc = @getTemplateFunction()

    if typeof templateFunc is 'function'
      # Call the template function passing the template data.
      html = templateFunc @getTemplateData()

      # Replace HTML
      @$el.html html

    # Return the view.
    this

  # This method is called after a specific `render` of a derived class.
  attach: ->
    # Automatically append to DOM if the container element is set.
    if @container
      # Append the view to the DOM.
      $(@container)[@containerMethod] @el
      # Trigger an event.
      @trigger 'addedToDOM'
    return

  # I18n shortcuts
  # --------------

  t: =>
    @model.get('configuration').i18n.t arguments...

  template: =>
    @model.get('configuration').i18n.template arguments...

  joinList: =>
    @model.get('configuration').i18n.joinList arguments...

  # Disposal
  # --------

  disposed: false

  dispose: ->
    return if @disposed

    # Dispose subviews.
    subview.dispose() for subview in @subviews

    # Unbind handlers of global events.
    @unsubscribeAllEvents()

    # Remove all event handlers on this module.
    @off()

    # Remove the topmost element from DOM. This also removes all event
    # handlers from the element and all its children.
    @remove()

    # Remove element references, options,
    # model/collection references and subview lists.
    properties = [
      'el', '$el',
      'options', 'model', 'collection',
      'subviews', 'subviewsByName',
      '_callbacks'
    ]
    delete this[prop] for prop in properties

    # Finished.
    @disposed = true

    # You’re frozen when your heart’s not open.
    Object.freeze? this

module.exports = View
