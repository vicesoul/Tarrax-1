require [
  'jquery'
  'compiled/tinymce'
  'tinymce.editor_box'
], ($) ->
	$ ->
		$("#content form textarea").editorBox()
