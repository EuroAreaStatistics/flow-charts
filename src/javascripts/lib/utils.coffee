# Adapted from Chaplin 0.9 (MIT-licensed)
# https://github.com/chaplinjs/chaplin/blob/0.9.0/src/chaplin/lib/utils.coffee

'use strict'
_ = require 'lodash'

utils =

  # String Helpers
  # --------------

  # Upcase the first character.
  upcase: (str) ->
    str.charAt(0).toUpperCase() + str.substring(1)

  # Constants
  # ---------

  # Chart format
  FORMAT_DEFAULT: 'default'
  FORMAT_THUMBNAIL: 'thumbnail'

  # Methods
  # -------

  # setTimeout with a sane signature
  after: (wait, fn) ->
    setTimeout fn, wait

  # Sorts elements by their volume (descending)
  elementsSorter: (a, b) ->
    b.model.sum - a.model.sum

  # Sorts relations by their value (descending)
  relationSorter: (a, b) ->
    b.value - a.value

Object.freeze? utils

module.exports = utils
