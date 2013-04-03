require [
  'jquery',
  'jqueryui/accordion'
], ($) ->

  $ ->

    $("#accordion").accordion(
      heightStyle: "content"
      collapsible: true
    )

    $(".clickable").click ->
      window.location.href = $(this).attr("href")

