require [
  'jquery'
  'compiled/tinymce'
  'tinymce.editor_box'
], ($) ->
	$ ->
		$("#case-tpl-widget textarea").editorBox()
