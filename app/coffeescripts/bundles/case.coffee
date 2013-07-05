require [
  'jquery'
  'compiled/tinymce'
  'tinymce.editor_box'
], ($) ->
  $ ->
    # tpl_new = $("#case_tpl_new").size() is 1

    $(".case-tpl:not('#hidden-tpl')").each (i)->
      $(this).attr 'id', 'case-' + i
    $("#case-tpl-widget textarea").editorBox tinyOptions:
      width: '100%'

    $('#new-module').on 'click',  (e)->
      e.preventDefault()
      lastSeqVal = $('#case-tpl-widget').find('input[name="case_tpl_widget[][seq]"]:last').val() or -1
      $newModule = $('#hidden-tpl').clone().show()
      $newModule.attr 'id', 'case-' + $(".case-tpl").size()
      $('#case-tpl-widget').append $newModule

      $newModule.find("textarea").editorBox tinyOptions:
        width: '100%'

      $('#case-tpl-widget').find('input[name="case_tpl_widget[][seq]"]:last').val(-(-lastSeqVal)+1)

    $('.remove-me').live 'click', ->
      $(this).parents('.case-tpl').remove()
      return false

    $('#tpl-selector').on 'change', ->
      selectorVal = $(this).val()
      if -(-selectorVal) > 0
        $.get '/courses/' + ENV.context_id + '/get_account_case_tpl/' + selectorVal, (data) ->
          $('#case-tpl-widget').remove()
          $('#tpl-area').append(data)
          $(data).find("textarea").editorBox tinyOptions:
            width: '100%'
