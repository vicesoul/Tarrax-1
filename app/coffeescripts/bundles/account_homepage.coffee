require [
  'jquery',
  'jqueryui/sortable',
  'jqueryui/dialog',
  'jqueryui/effects/highlight'
  'compiled/tinymce',
  'tinymce.editor_box',
  'jquery.form'
], ($)->
  
  synToDialog = ($obj) ->
    $("#widget_title").val $.trim( $obj.find(".data-widget-title").text() )
    $("#widget_body")._setContentCode $obj.find(".data-widget-body").html()

  synToWidget = ($obj)->
    $obj.find(".data-widget-title").text $("#widget_title").val()
    $obj.find(".data-widget-body").html $("#widget_body")._getContentCode()

  resetPosition = ->
    $(".jxb_page_position").remove()
    $("[data-position]").each ->
      position = $(this).attr("data-position")
      widgets  = $(this).find("[data-widget]")
      if widgets.length
        $.each widgets, (index, widget) ->
          $(".edit_jxb_page").append widgetAttributes( "#{position}_#{index}", $(widget) )

  widgetAttributes = (position, widget) ->
    data  = widget.attr("data-widget")
    if widget.hasClass("deleted")
      """
      <input class="jxb_page_position" name="jxb_page[positions][#{position}][widget]" type="hidden" value="#{data}" />
      <input class="jxb_page_position" name="jxb_page[positions][#{position}][delete]" type="hidden" value="1" />
      """
    else
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
      $widget.addClass("deleted")
      $widget.hide()
    $widgets.addClass("deletable").append($deleteImg)
    $widgets.each ->
      unless $(this).hasClass "fixed"
        $editImg = $("<img src='/images/edit.png' title='edit' class='edit_widget' />").click ->
          $('.editable').removeClass('editable')
          $widget = $(this).parent("[data-widget]")
          synToDialog( $widget )
          $("#edit_widget_dialog").dialog "open"
          $widget.addClass('editable')
        $(this).append $editImg

  makePositionClickable = ->
    $(".theme_edit [data-position]").click ->
     $(".theme_edit .position_selected").removeClass "position_selected"
     $(this).addClass "position_selected"
     $(this).effect('highlight', {}, 500)

  makePositionUnclickable = ->
    $("[data-position]").unbind 'click'
    
  revertWidgets = ->
    $("[data-widget]").removeClass("deletable").removeClass("deleted").show()
    $(".delete_widget").remove()
    $(".edit_widget").remove()

  $ ->
    
    $("#content").css("overflow", "scroll")

    $(".sortable").sortable(
      connectWith: ".sortable"
      cursor: "move"
      start: (event, ui) ->
        ui.placeholder.width  ui.item.width()
        ui.placeholder.height ui.item.height()
    )
    
    $("#widget_body").editorBox tinyOptions: width: '100%'

    $("#edit_widget_dialog").dialog(
      autoOpen: false
      width: 800
      height: 600
    )
    
    $chooseCoursesDialog = $("#choose_courses_dialog").dialog(
      autoOpen: false
      width: 400
      height: 300
    )

    $changeBackgroundDialog = $("#change_background_dialog").dialog(
      autoOpen: false
      width: 400
      height: 300
    )

    $(".account_name_checkbox").click ->
      $allBox = $(this).next(".all_sub_checkboxs").find("input[type='checkbox']")
      if $(this).is ":checked"
        $allBox.attr("checked", "checked")
      else
        $allBox.removeAttr("checked")

    $(".save_choose_courses_link").click ->
      $("form.edit_jxb_page #theme_options input.pending").remove()
      $allBox = $(".all_sub_checkboxs input[type='checkbox']:checked").addClass("pending")
      $("form.edit_jxb_page #theme_options").append $allBox.clone()
      $chooseCoursesDialog.dialog "close"

    $("#link_to_choose_courses_dialog").click ->
      $("#choose_courses_dialog").dialog "open"

    $("#link_to_change_background_dialog").click ->
      $changeBackgroundDialog.dialog "open"

    $(".save_widget_button").click ->
      synToWidget( $('.editable') )
      $("#edit_widget_dialog").dialog "close"

    $(".save_background_button").click ->
      $target = $('[data-bg-varied="true"]')
      color  = if $("#page_background_color").val() == '' then 'transparent' else $("#page_background_color").val()
      repeat = if $("#repeat").prop("checked") then 'repeat' else 'no-repeat'
      url    = if $("#background_image_holder img").attr('src') then "url( #{ $('#background_image_holder img').attr('src') } )" else null
      default_position = $("[data-bg-default-position]").attr('data-bg-default-position') || 'top center'
      position = if url? then 'top center' else default_position
      background_style = "background-color: #{color};background-repeat: #{repeat} no-repeat;background-position: #{position};"
      background_style += "background-image: #{url};" if url?
      $('#jxb_page_background_image').val background_style
      $target.css('background-color', color)
      $target.css('background-repeat', "#{repeat} no-repeat")
      $target.css('background-position', position)
      $target.css('background-image', url) if url?
      $changeBackgroundDialog.dialog "close"
    
    $("#delete_background_image").click ->
      $("#background_image_holder").html ''

    # make disable default
    $(".sortable").sortable("disable")

    $(".edit_theme_link").click ->
      $(this).hide()
      $("#content-wrapper").addClass("theme_edit")
      $("form.edit_jxb_page").show()
      $(".sortable").sortable("enable")
      makeWidgetsDeletable()
      makePositionClickable()

    $("form.edit_jxb_page a.cancel").click ->
      $(".sortable").sortable("cancel")
      $(".sortable").sortable("disable")
      revertWidgets()
      $("#content-wrapper").removeClass("theme_edit")
      $("form.edit_jxb_page").hide()
      $(".jxb_page_position").remove()
      $(".new_widget").remove()
      $(".edit_theme_link").show()
      makePositionUnclickable()

    $("#add_widget").click ->
      name = $("#widget_name").val()
      $container = if $(".position_selected").length > 0 then $(".position_selected") else $("[data-position]:last")
      $.ajax(
        url: $("#widget_url").val()
        data: { name:name }
        beforeSend: () ->
          $("#add_widget").hide()
          $(".add_widget_loading_icon").show()
      ).success (data)->
        $data = $(data).addClass("new_widget_ajax")
        $container.append($data)
        makeWidgetsDeletable()
        $('body').animate({
          scrollTop: $data.offset().top
        }, 500, -> $data.effect('highlight', {}, 500) )
        $(".add_widget_loading_icon").hide()
        $("#add_widget").show()

    $("form.edit_jxb_page").submit ->
      resetPosition()
      return true

    $("#widget_image_uploader").submit ->
      $(this).ajaxSubmit(
        beforeSubmit: ->
          return false if $("#widget_image").val() == ""
        success: (data)->
          img = """
                <img src="#{data.url}" />
                """
          $("#widget_body").editorBox "insert_code", img
          $("#widget_image").val ""
      )
      return false

    $("#background_image_uploader").submit ->
      $(this).ajaxSubmit(
        beforeSubmit: ->
          return false if $("#background_bg_image").val() == ""
        success: (data)->
          img = """
                <img src="#{data.url}" />
                """
          $("#background_image_holder").html img
          $("#background_bg_image").val ""
      )
      return false
