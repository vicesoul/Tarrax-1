require [
  'jquery'
  'i18n!account_homepage'
  'jqueryui/sortable'
  'jqueryui/draggable'
  'jqueryui/dialog'
  'jqueryui/effects/highlight'
  'compiled/tinymce'
  'tinymce.editor_box'
  'jquery.form'
  'jqueryui/easyDialog'
  'quizzes_new'
], ($, I18n)->

  matchWidget = [ 
    ["announcement,account", "announcement_account"], 
    ["activity", "activity"], 
    ["discussion", "discussion"], 
    ["course", "course"], 
    ["announcement,index", "announcement_index"], 
    ["assignment", "assignment"], 
    ["logo", "logo"] 
  ]

  isCustom = false

  $allArea = {}

  $customArea = {}

  synToDialog = ($widget) ->
    $("#widget_title").val $.trim( $widget.find(".data-widget-title").text() )
    $("#widget_body")._setContentCode $widget.find(".data-widget-body").html()
    url = $widget.find(".data-widget-url").html()
    $(".type-url input").val url

  synToWidget = ($widget)->
    $widget.find(".data-widget-title").text $("#widget_title").val()
    url = $(".type-url input").val()
    $widget.find(".data-widget-url").html url
    $widget.find(".data-widget-body").html $("#widget_body")._getContentCode()

  resetPosition = ->
    $(".jxb_page_position").remove()
    $("[data-position]").each ->
      position = $(this).attr("data-position")
      widgets  = $(this).find("[data-widget]")
      if widgets.length
        $.each widgets, (index, widget) ->
          $(".edit_jxb_page").append widgetAttributes( "#{position}_#{index}", $(widget) )

  widgetAttributes = (position, $widget) ->
    data  = $widget.attr("data-widget")
    if $widget.hasClass("deleted")
      """
      <input class="jxb_page_position" name="jxb_page[positions][#{position}][widget]" type="hidden" value="#{data}" />
      <input class="jxb_page_position" name="jxb_page[positions][#{position}][delete]" type="hidden" value="1" />
      """
    else
      title = $widget.find(".data-widget-title").text()
      body  = $widget.find(".data-widget-body").html()
      url = $widget.find(".data-widget-url").html()
      """
      <input class="jxb_page_position" name="jxb_page[positions][#{position}][widget]" type="hidden" value="#{data}" />
      <input class="jxb_page_position" name="jxb_page[positions][#{position}][title]" type="hidden" value="#{title}" />
      <textarea class="jxb_page_position" name="jxb_page[positions][#{position}][iframe_url]" style="display:none;">#{url}</textarea>
      <textarea class="jxb_page_position" name="jxb_page[positions][#{position}][body]" style="display:none;">#{body}</textarea>
      """
  toggleGhost = ( sort, drag )->
    hasWidget = $("div[data-widget^='" + sort + "']").filter(":visible").size() isnt 0
    $("#homepage-editor-left-side li[cptype^='" + drag + "']").draggable if hasWidget then "disable" else "enable"
    # $("#homepage-editor-left-side li[cptype^='" + draggable + "']")[ if flag then "addClass" else "removeClass" ] "ghost"

  makeWidgetsDeletable = ->
    $widgets = $("[data-widget]").not(".deletable")
    $deleteImg = $("<img src='/images/delete.png' title='delete' class='delete_widget' />").click ->
      $widget = $(this).parent(".deletable")
      $widget.addClass("deleted")
      $widget.hide()
      toggleGhost.apply {}, widget for widget in matchWidget

    $widgets.addClass("deletable").append($deleteImg)
    $widgets.each ->
      unless $(this).hasClass "fixed"
        $editImg = $("<img src='/images/edit.png' title='edit' class='edit_widget' />").click ->
          $('.editable').removeClass('editable')
          $widget = $(this).parent("[data-widget]")
          synToDialog( $widget )
          $("#edit_widget_dialog").dialog(
            open: (event, ui) ->
              dataPosition = $widget.closest(".sortable").attr("data-position") 
              widget = $widget.attr("data-widget").split(",")[0]
              if dataPosition isnt "nav" and widget is "custom" or dataPosition is 'logo'
                $(this).addClass "has-title"
              else if widget is "activity"
                $(this).addClass "no-title"
            beforeClose: (event, ui) ->
              $(this).removeClass "has-title no-title"
          ).dialog('open')
          $widget.addClass('editable')
        $(this).append $editImg

  makePositionUnclickable = ->
    $("[data-position]").off 'click'
    
  revertWidgets = ->
    $("[data-widget]").removeClass("deletable").removeClass("deleted").show()
    $(".delete_widget").remove()
    $(".edit_widget").remove()

  initEditButton = ->
    $(".sortable").sortable("enable")
    $("#content-wrapper").addClass("theme_edit")
    makeWidgetsDeletable()

  ajaxItem = (name, $context, $container, $this)->
    $.ajax(
      url: $("#widget_url").val()
      data: { name:name }
    ).success (data)->
      $data = $(data).addClass("new_widget_ajax")

      if $container.length == 0
        $container = $this.find('[data-widget]:first')
        if $container.length == 0
          $this.append($data)
        else
          $container.before($data)
      else
        $container.after($data)

      $('[data-position]').find('.editor-component').remove()
      makeWidgetsDeletable() 

  connectTo = ($draggable, $sortable)->
    $draggable.draggable "option", "connectToSortable", $sortable
    # highlight droppable area
    $draggable.on( "dragstart", ( event, ui ) ->
      widget = $(this).attr("cptype")
      if widget is "custom_index"
        isCustom = true
      else
        isCustom = false
      highlight($sortable)
    )


  initConnectWith = ->
    dataWidget = $(this).closest(".deletable").attr("data-widget")
    # fix bug that when drag,  fake self had no pro "data-widget"
    if !dataWidget
      return false
    widget = dataWidget.split(',')[0]
    if widget is "custom"
      isCustom = true
      $customArea.sortable "option", "connectWith", $customArea
      $customArea.on( "sortstart", highlight )
    else
      isCustom = false
      $selfArea = $(this).closest(".sortable")
      $selfArea.sortable "option", "connectWith", $selfArea   # only sortable to self
      $selfArea.on( "sortstart", highlight )

  deleConnectWith = ->
    $allArea.off( "sortstart" )

  highlight = ($draggable)->
    $sortable = if $(this)[0] is window then $draggable else $(this)
    $area = if isCustom then $customArea else $sortable
    $area.addClass "position_selected"

  # dom ready  
  $ ->

    $editPage = $(".edit_theme_link")
    $saveSet = $(".save-set")
    $leftNav= $("#left-side > nav")
    $widgets= $("#left-side > .widgets")

    $editPage.click (e)->
      e.preventDefault()
      initEditButton()
      $widgets.show()
      $leftNav.hide()
      $saveSet.show()
      $(this).hide()

    $(".save_theme_link").click (e)->
      e.preventDefault()
      $('form.edit_jxb_page').submit()

    $(".cancel-edited").click (e)->
      e.preventDefault()
      location.reload()
      # fn = ->
      #   $(".sortable").sortable("cancel")
      #   $('[data-position]').find('.add_widget_icon').remove()
      #   $(".sortable").sortable("disable")
      #   revertWidgets()
      #   $("#content-wrapper").removeClass("theme_edit")
      #   $(".jxb_page_position").remove()
      #   $(".new_widget_ajax").remove()
      #   $(".edit_theme_link").show()
      #   makePositionUnclickable()

      # if $(".new_widget_ajax").size() != 0
      #   $('<div></div>').easyDialog({
      #     confirmButton: '请帮我取消'
      #     confirmButtonClass: 'btn-primary'
      #     content: '您有新添加的组件未保存<br/ ><br />确定要取消之前所有的编辑操作吗？'
      #     confirmCallback: fn
      #   }, 'confirm')
      # else
      #   fn()


    # init sortable
    $(".sortable").sortable
      revert: true
      disabled: true
      # handle: ".box_head"
      cursor: "move"
      start: (event, ui) ->
        ui.placeholder.width  ui.item.width()
        ui.placeholder.height ui.item.height()
      stop: (event, ui) ->
        if ui.item.hasClass 'editor-component'
          name = ui.item.attr('cpType')
          $context = ui.item
          $container = ui.item.prev()
          ajaxItem name, $context, $container, $(this)

          # only custom widget could exit more than one
          if ui.item.attr("cptype") isnt "custom_index"
            widget = ui.item.attr("cptype")
            $("#homepage-editor-left-side li[cptype=" + widget + "]").draggable "disable"

        #reset highlight
        $allArea.removeClass "position_selected"

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

    $changeTheme = $(".edit_jxb_page").dialog(
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

    $(".connect_course").click ->
      $("#choose_courses_dialog").dialog "open"

    $(".chagne_bg").click ->
      $changeBackgroundDialog.dialog "open"

    $(".save_widget_button").click ->
      synToWidget( $('.editable') )
      $("#edit_widget_dialog").dialog "close"

    $(".chagne_theme").click ->
      $changeTheme.dialog "open"

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

    $('.reset_theme').click ->
      _this = $(this)
      $('<div></div>').easyDialog({
        content: '您确定要重置主页吗？该操作是不可逆的!'
        confirmButtonClass: 'btn-primary'
        confirmCallback: ->
          window.location.href = _this.attr('href')
      }, 'confirm')
      return false

    $tipB = $("<div class='tipB' style='position: absolute; font-size: 12px; color: red; z-index: 11;'>" + I18n.t('tip.drag', 'drag & move to a new area') + "</div>")
    $tipB.appendTo("body").hide()

    $(".theme_edit .box_head").live(
      mouseenter: ->
        position = $(this).offset()

        $tipB.show().css({
          left: position.left
          top: position.top - 15
          })

      mouseleave: ->
        $tipB.hide()
    )


      

    #themes selector onchange  
    $('#jxb_page_theme').change ->
      $('<div></div>').easyDialog({
        confirmButton: '确定'
        confirmButtonClass: 'btn-primary'
        content: "您确定要更换主页的主题为<span style='font-weight:bold;color:red;font-size:14px;'>#{$('#jxb_page_theme').val()}</span>吗？"
        confirmCancelCallback: ->
          $('#jxb_page_theme').val($('#jxb_page_theme').prop('defaultSelected'))
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

    $("form.edit_jxb_page").submit ->
      resetPosition()
      return true

    $("#widget_image_uploader, #background_image_uploader").submit (e)->
      e.preventDefault()
      $form = $(this)
      $textUploading = $("<span>上传中...</span>")
      $confirm = $form.find(".confirm")

      $form.ajaxSubmit(
        clearForm: true
        dataType: 'json'
        beforeSubmit: ->
          imageValidated = validateUploadedImage( $form.find("input[type=file]").val() )
          if imageValidated 
            $confirm.hide().after($textUploading)
          return imageValidated;
        success: (data)->
          img = """
                <img src="#{data.url}" />
                """

          if $form.is("#widget_image_uploader")
            $("#widget_body").editorBox "insert_code", img
          else
          $("#background_image_holder").html img
          
          $confirm.show()
          $textUploading.remove()
        complete: ->
          afterUploadedImageSuccess()
      )
      #tooltip
      $('.account_announcement, #add_widget').tooltip({
        position: { my: "left bottom+30", at: "left bottom" }
        })

    

    $("#homepage-editor-left-side").on "mousedown", ->
      return false

    $customArea = $( ".sortable[data-position=center], .sortable[data-position=right], .sortable[data-position=nav]" )
    $center = $( ".sortable[data-position=center]" )
    $right = $( ".sortable[data-position=right]" )
    $nav = $( ".sortable[data-position=nav]" )
    $caption = $( ".sortable[data-position=caption]" )
    $logo = $( ".sortable[data-position=logo]" )
    $phone = $( ".sortable[data-position=phone]" )

    $allArea = $customArea.add($logo).add($caption).add($phone)

    # init draggable
    $('.editor-component').draggable
      helper: "clone"
      revert: "invalid"
      stop: (event, ui) ->
        #reset highlight
        $allArea.removeClass "position_selected"

    # init left draggable
    toggleGhost.apply {}, widget for widget in matchWidget

    # set droppable area
    connectTo $('.editor-component[cptype=logo_index]'), $logo
    centerWidget = '.editor-component[cptype=activity_index],' +
      '.editor-component[cptype=announcement_index],' +
      '.editor-component[cptype=assignment_index],' +
      '.editor-component[cptype=discussion_index],' +
      '.editor-component[cptype=course_index]'
    connectTo $(centerWidget), $center
    connectTo $('.editor-component[cptype=custom_index]'), $customArea 
    connectTo $('.editor-component[cptype=announcement_account]'), $right

    # set droppable area
    $(".sortable").on "mouseenter", ".deletable", initConnectWith
    $(".sortable").on "mouseleave", ".deletable", deleConnectWith
      


