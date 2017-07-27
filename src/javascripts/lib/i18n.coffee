'use strict'
_ = require 'lodash'

TEMPLATE_OPTIONS = interpolate: /%\{(.+?)\}/g

class I18n

  constructor: (@locale) ->
    @compiledTemplates = {}

  # Returns the translation for the given key path (array of strings).
  # t(['one', 'two', 'three'])
  t: (keys...) =>
    tree = @locale
    lastIndex = keys.length - 1
    for key, index in keys
      tree = tree[key]
      type = typeof tree
      if type is 'undefined'
        console.error 'Translation not found:', keys
        return ''
      if index is lastIndex
        return tree

  # Returns a translation using a template for the given key path
  # template(['one', 'two', 'three'], {…})
  template: (keys, data) =>
    cacheKey = keys.join '.'
    templateFunction = @compiledTemplates[cacheKey]
    unless templateFunction
      template = @t keys...
      templateFunction = _.template template, null, TEMPLATE_OPTIONS
      @compiledTemplates[cacheKey] = templateFunction
    templateFunction data

  # For a list of strings ['a', 'b', 'c'],
  # return a localized string 'a, b and c'.
  joinList: (elements) ->
    if elements.length > 1
      _.initial(elements).join(
        @t('enum_separator')
      ) +
      @t('enum_separator_last') +
      _.last(elements)
    else
      elements[0]

module.exports = I18n
