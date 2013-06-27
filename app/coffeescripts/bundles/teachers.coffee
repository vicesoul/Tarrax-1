require [
  'jquery'
], ($) ->
  $(document).on 'click', '#check_all', ->
    $('tbody').find('input:checkbox').prop 'checked', $(this).prop('checked')
