require [
  'quiz_inputs'
  'quiz_show'
  'quiz_rubric'
  'message_students'
], (inputMethods) ->
  $ ->
    inputMethods.setWidths()
    $('.answer input[type=text]').each ->
      $(this).width(($(this).val().length or 11) * 9.5)
    
    $(".toggle_solution").click (event)->
      event.preventDefault()
      $solution_text = $(this).next()
      if $solution_text.is(":visible")
        $(this).text $(this).attr("data-show-text")
      else
        $(this).text $(this).attr("data-hide-text")
      $(this).next().toggle()
