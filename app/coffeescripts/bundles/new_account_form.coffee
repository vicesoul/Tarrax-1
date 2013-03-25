require [
  'jquery'
  'jquery.disableWhileLoading'
], ($) ->
  $ ->
    changeEvents = 'change keyup input'
    showCourseCodeIfNeeded = ->
      if $nameInput.val().trim().length > 20
        $nameInput.unbind changeEvents, showCourseCodeIfNeeded
        $('#account_code_wrapper').slideDown('fast')

    $nameInput = $('#new_account_form [name="account[name]"]')
    $nameInput.bind changeEvents, showCourseCodeIfNeeded
    $('#new_account_form').submit -> $(this).disableWhileLoading($.Deferred())
