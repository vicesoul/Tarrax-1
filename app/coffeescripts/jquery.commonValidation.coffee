
define [
  'jquery'
], ($) ->
  Validation = 
    isEmail:  (str)->
      /^([_a-zA-Z\d\-\.])+@([a-zA-Z0-9_-])+(\.[a-zA-Z0-9_-])+/.test str
  return Validation
