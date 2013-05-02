require [
  'jquery',
  'i18n!homepage_dialog'
  'jqueryui/sortable',
  'jqueryui/draggable',
  'jqueryui/dialog',
  'jqueryui/effects/highlight'
  'compiled/tinymce',
  'tinymce.editor_box',
  'jquery.form',
  'jqueryui/easyDialog'
], ($, I18n)->
  
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
          $("#edit_widget_dialog").dialog(
            open: (event, ui) ->
              $('#edit-widget-dialog-title').hide() if $widget.attr('data-widget').split(',')[0] == 'logo'
              $('#widget_body_toolbargroup').parent().hide() if $widget.attr('data-widget').split(',')[0] == 'activity'
            beforeClose: (event, ui) ->
              $('#edit-widget-dialog-title').show()
              $('#widget_body_toolbargroup').parent().show()
          ).dialog('open')
          $widget.addClass('editable')
        $(this).append $editImg

  makePositionClickable = ->
     $(".theme_edit [data-position]").bind(
       click: ->
         $(".theme_edit .position_selected").removeClass "position_selected"
         $(this).addClass "position_selected"
         $(this).effect('highlight', {}, 500)
       #dblclick: ->
         #$('#add_widget_dialog').dialog();
     )

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
    
    $("#widget_body").editorBox tinyOptions:
      width: '100%'
      mode: "textareas"
      iframe_width: '300px'

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
      $('#fixed_right_sider').draggable()
      $(this).hide()
      $("#content-wrapper").addClass("theme_edit")
      $("form.edit_jxb_page").show()
      $(".sortable").sortable("enable")
      $("#add_widget").draggable(
        connectToSortable: ".sortable"
        helper: "clone"
        revert: "invalid"
      )
      makeWidgetsDeletable()
      makePositionClickable()

      #############################
      $(".sortable").sortable(
        revert: true
        stop: (event, ui) ->
          if ui.item.hasClass 'add_widget_icon'
            name = $("#widget_name").val()
            #$container = if $(".position_selected").length > 0 then $(".position_selected") else $("[data-position]:last")
            $context = ui.item
            $container = ui.item.prev()
            _this = $(this)
            $.ajax(
              url: $("#widget_url").val()
              data: { name:name }
              beforeSend: () ->
                $("#add_widget").hide()
                $(".add_widget_loading_icon").show()
            ).success (data)->
              $data = $(data).addClass("new_widget_ajax")
              
              if $container.length == 0
                $container = _this.find('[data-widget]:first')
                if $container.length == 0
                  _this.append($data)
                else
                  $container.before($data)
              else
                $container.after($data)
              $('[data-position]').find('.add_widget_icon').remove()
              $(".sortable").sortable()
              makeWidgetsDeletable()
              $('body').animate({
                scrollTop: $data.offset().top
              }, 500, -> $data.effect('highlight', {}, 500) )
              $(".add_widget_loading_icon").hide()
              $("#add_widget").show()

      )
      return
      #############################

    $("form.edit_jxb_page button.cancel").click ->
      fn = ->
        $(".sortable").sortable("cancel")
        $('[data-position]').find('.add_widget_icon').remove()
        $(".sortable").sortable("disable")
        revertWidgets()
        $("#content-wrapper").removeClass("theme_edit")
        $("form.edit_jxb_page").hide()
        $(".jxb_page_position").remove()
        $(".new_widget_ajax").remove()
        $(".edit_theme_link").show()
        makePositionUnclickable()

      if $(".new_widget_ajax").size() != 0
        $('#jxb-message-dialog').easyDialog({
          confirmButton: '请帮我取消'
          confirmButtonClass: 'btn-primary'
          content: '您有新添加的组件未保存<br/ ><br />确定要取消之前所有的编辑操作吗？'
          confirmCallback: fn
        }, 'confirm')
      else
        fn()
      return false

    #themes selector onchange  
    $('#jxb_page_theme').bind({
      change: ->
        $('#jxb-message-dialog').easyDialog({
          confirmButton: '我确定更换主题'
          confirmButtonClass: 'btn-primary'
          content: '您确定要更换主页的主题吗？'
          confirmCancelCallback: ->
             $('#jxb_page_theme').val($('#jxb_page_theme').prop('defauleSelected'))
          confirmCallback: ->
            $.ajaxJSON(
              $('#hidden_update_theme_url').val() + $('#jxb_page_theme').val(),
              'post',
              {},
              (data) ->
                if data.flag
                  window.location.reload()
                else
                  alert '更换主题失败，请重试!'

            )
        }, 'confirm')
    })

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
          return validateUploadedImage $("#widget_image").val()
        success: (data)->
          img = """
                <img src="#{data.url}" />
                """
          $("#widget_body").editorBox "insert_code", img
          $("#widget_image").val ""
          afterUploadedImageSuccess()
      )
      return false

    $("#background_image_uploader").submit ->
      $(this).ajaxSubmit(
        beforeSubmit: ->
          return validateUploadedImage $("#background_bg_image").val()
        success: (data)->
          img = """
                <img src="#{data.url}" />
                """
          $("#background_image_holder").html img
          $("#background_bg_image").val ""
          afterUploadedImageSuccess()
      )
      return false

    init = ->
      $("#widget_image").change(->
        $('#widget_image_uploader').submit()
      )
      $("#background_bg_image").change(->
        $('#background_image_uploader').submit()
      )
      #tooltip
      $('.account_announcement, #add_widget').tooltip()
      #stage current theme
      #$('#jxb_page_theme').val($('#jxb_page_theme').prop('defauleSelected'));

    validateUploadedImage = (imageVal)->
      flag = true
      content = I18n.t('#accounts.homepage.dialog.error.empty_image', 'Please confirm your image is not empty')
      if imageVal == ''
        flag = false
      else if !(/\.(?:png|jpg|jpeg|bmp|gif)$/i.test imageVal)
        content = I18n.t('#accounts.homepage.dialog.error.incorrect_image_type', 'Please confirm your image type is correct')
        flag = false
      unless flag
        $('#jxb-message-dialog').easyDialog({
          modal: true
          content: content
        })
      return flag

    afterUploadedImageSuccess = ->
      $('#jxb-message-dialog').easyDialog({
        modal: true
        content: I18n.t('#accounts.homepage.dialog.tip.uploaded_success', "Image has bean uploaded")
      })

    $(document).ready(
      ->
        init()
    )
