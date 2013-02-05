require [
  'jquery',
  'jqueryui/sortable'
], ($)->

  $ ->
    resetPosition = ->
      $(".jxb_page_position").remove()
      $("[data-position]").each ->
        position = $(this).attr("data-position")
        widgets  = $(this).find("[data-widget]:visible")
        if widgets.length
          widgets.each ->
            $(".edit_jxb_page").append hiddenPosition position, $(this).attr("data-widget")

    hiddenPosition = (position, widget) ->
      """
      <input class="jxb_page_position" name="jxb_page[positions][#{position}][]" type="hidden" value="#{widget}" />
      """

    makeWidgetsDeletable = ->
      $widgets = $("[data-widget]").not(".deletable")
      $img = $("<img src='/images/delete.png' title='delete' class='delete_widget' />").click ->
        $widget = $(this).parent(".deletable")
        $widget.hide()
      $widgets.addClass("deletable").append($img)
    
    revertWidgets = ->
      $("[data-widget]").removeClass("deletable").show()
      $(".delete_widget").remove()

    $(".sortable").sortable(
      connectWith: ".sortable"
      cursor: "move"
      start: (event, ui) ->
        ui.placeholder.width  ui.item.width()
        ui.placeholder.height ui.item.height()
    )

    # make disable default
    $(".sortable").sortable("disable")

    $(".edit_theme_link").click ->
      $(this).hide()
      $("form.edit_jxb_page").show()
      $(".sortable").sortable("enable")
      makeWidgetsDeletable()

    $("form.edit_jxb_page a.cancel").click ->
      $(".sortable").sortable("cancel")
      $(".sortable").sortable("disable")
      revertWidgets()
      $("form.edit_jxb_page").hide()
      $(".jxb_page_position").remove()
      $(".new_widget").remove()
      $(".edit_theme_link").show()

    $("#add_widget").click ->
      name = $("#widget_name").val()
      $container = $("[data-position]:last")
      $.ajax(
        url: $("#widget_url").val()
        data: { name:name }
      ).success (data)->
        $data = $(data).addClass("new_widget_ajax")
        $container.append($data)
        makeWidgetsDeletable()

    $("form.edit_jxb_page").submit ->
      resetPosition()
      return true
