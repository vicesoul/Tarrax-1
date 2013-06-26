# examples:
#
#     $('.editor').richEditor();
#
# and you will get a tinymce editor with witch view link floating before that

define [
  'jquery'
  'i18n!richeditor'
  'compiled/tinymce'
  'tinymce.editor_box'
], ($, I18n)->
  $.fn.richEditor = ->
    $(this).each (index, el)->
      $(this).css('width', '100%')
      $(this).editorBox()
      $(this).before "<div style='float: right'><a href='#' class='switch_richeditor_views'>#{I18n.t('#links.switch_views', 'Switch Views')}</a></div><div class='clearfix'></div>"

  $(document).on 'click', '.switch_richeditor_views', (e)->
    e.preventDefault()
    $(this).parent().next().next().editorBox('toggle')
