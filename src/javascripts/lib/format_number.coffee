'use strict'
decimalAdjust = require 'decimal-adjust'

# Formats 123456.789 as 123,456.789
# Cuts off decimals if the number gets high
# Cuts off zeros in decimals
formatNumber = (configuration, number, decimals = null, forceDecimals = false,
  html = false) ->
  t = configuration.i18n.t
  decimals ?= configuration.decimals

  str = decimalAdjust('round', Number(number), -decimals).toFixed decimals

  pointPos = str.indexOf '.'
  pointPos = str.length if pointPos is -1

  int = str.substring 0, pointPos
  if str.charAt(0) is '-'
    sign = '-'
    int = int.substring 1
  else
    sign = ''

  fraction = str.substring pointPos + 1

  # Add thousands separators
  thousandsSeparator = t(
    "thousands_separator#{if html then '_html' else ''}"
  )
  str = ''
  i = int.length
  consumed = 0
  while i-- > 0
    if consumed is 3
      str = int.charAt(i) + thousandsSeparator + str
      consumed = 0
    else
      str = int.charAt(i) + str
    consumed++

  # Only add the decimals if the integer is less then 4 digits
  decimalMark = t 'decimal_mark'
  if (forceDecimals or str.length < 4) and fraction.length > 0
    str += decimalMark + fraction
  else if decimals > 0
    # Reformat without decimals for correct rounding
    return formatNumber configuration, number, 0, forceDecimals, html

  # Add sign again
  str = sign + str

  str

module.exports = formatNumber
