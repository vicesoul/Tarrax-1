require [
  'jquery',
  'jqueryui/sortable',
  'jqueryui/dialog',
  'compiled/tinymce',
  'tinymce.editor_box'
], ($)->
  
  synToDialog = ($obj) ->
    $("#widget_title").val $obj.find(".data-widget-title").text()
    #$("#widget_body").val $obj.find(".data-widget-body").html()
    $("#widget_body")._setContentCode $obj.find(".data-widget-body").html()

  synToWidget = ($obj)->
    $obj.find(".data-widget-title").text $("#widget_title").val()
    $obj.find(".data-widget-body").html $("#widget_body")._getContentCode()

  resetPosition = ->
    $(".jxb_page_position").remove()
    $("[data-position]").each ->
      position = $(this).attr("data-position")
      widgets  = $(this).find("[data-widget]:visible")
      if widgets.length
        $.each widgets, (index, widget) ->
          $(".edit_jxb_page").append hiddenPosition( "#{position}_#{index}", $(widget) )

  hiddenPosition = (position, widget) ->
    data  = widget.attr("data-widget")
    title = widget.find(".data-widget-title").text()
    body  = widget.find(".data-widget-body").html()
    """
    <input class="jxb_page_position" name="jxb_page[positions][#{position}][widget]" type="hidden" value="#{data}" />
    <input class="jxb_page_position" name="jxb_page[positions][#{position}][title]" type="hidden" value="#{title}" />
    <textarea class="jxb_page_position" name="jxb_page[positions][#{position}][body]" style="display:none;">#{body}</textarea>
    """

  makeWidgetsDeletable = ->
    $widgets = $("[data-widget]").not(".deletable")
    $deleteImg = $("<img src='/images/delete.png' title='delete' class='delete_widget' />").click ->
      $widget = $(this).parent(".deletable")
      $widget.hide()
    $editImg = $("<img src='/images/edit.png' title='edit' class='edit_widget' />").click ->
      $widget = $(this).parent("[data-widget]")
      synToDialog( $widget )
      $("#edit_widget_dialog").dialog "open"
      $widget.addClass('editable')
    $widgets.addClass("deletable").append($deleteImg).append($editImg)
    
  revertWidgets = ->
    $("[data-widget]").removeClass("deletable").show()
    $(".delete_widget").remove()
    $(".edit_widget").remove()

  $ ->

    $(".sortable").sortable(
      connectWith: ".sortable"
      cursor: "move"
      start: (event, ui) ->
        ui.placeholder.width  ui.item.width()
        ui.placeholder.height ui.item.height()
    )

    $("#edit_widget_dialog").dialog(
      autoOpen: false
      width: 800
      height: 600
    )

    $("#widget_body").editorBox tinyOptions: width: '100%'

    $(".save_widget_button").click ->
      synToWidget( $('.editable') )
      $("#edit_widget_dialog").dialog "close"

    # make disable default
    $(".sortable").sortable("disable")

    $(".edit_theme_link").click ->
      $(this).hide()
      $("#content-wrapper").addClass("theme_edit")
      $("form.edit_jxb_page").show()
      $(".sortable").sortable("enable")
      makeWidgetsDeletable()

    $("form.edit_jxb_page a.cancel").click ->
      $(".sortable").sortable("cancel")
      $(".sortable").sortable("disable")
      revertWidgets()
      $("#content-wrapper").removeClass("theme_edit")
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
