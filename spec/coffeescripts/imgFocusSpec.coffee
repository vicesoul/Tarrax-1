define [
#  'tinymce/jscripts/tiny_mce/tiny_mce_src'
  'vendor/underscore'
  'tinymce/jscripts/tiny_mce/plugins/instructure_drawing/editor_plugin'
], (_,Template) ->

  module 'imgFocus'
  test 'meme,mememememememememe', ->
    html = meme();
    equal html, 'me'
