##
# Requires all tinymce dependencies and prevents it from loading  assets

# 2012-11-21 rupert add hasFlash or isCanvasSupported
instrPlugins = [  'compiled/editor/markScriptsLoaded'
  'compiled/editor/stocktiny'

  # instructure plugins
  'tinymce/jscripts/tiny_mce/plugins/instructure_contextmenu/editor_plugin'
  'tinymce/jscripts/tiny_mce/plugins/instructure_embed/editor_plugin'
  'tinymce/jscripts/tiny_mce/plugins/instructure_equation/editor_plugin'
  'tinymce/jscripts/tiny_mce/plugins/instructure_equella/editor_plugin'
  'tinymce/jscripts/tiny_mce/plugins/instructure_external_tools/editor_plugin'
  'tinymce/jscripts/tiny_mce/plugins/instructure_links/editor_plugin'
 ]

isCanvasSupported = ->
  elem = document.createElement('canvas');
  !!(elem.getContext && elem.getContext('2d'));
if isCanvasSupported
  instrPlugins.push 'tinymce/jscripts/tiny_mce/plugins/instructure_drawing/editor_plugin'

hasFlash = swfobject.hasFlashPlayerVersion("9") and navigator.userAgent.match(/iPad/i) is null;
if hasFlash
 instrPlugins.push 'tinymce/jscripts/tiny_mce/plugins/instructure_record/editor_plugin'
# end

define instrPlugins, (markScriptsLoaded, tinymce) ->

  # mark everything we just loaded as done
  markScriptsLoaded [
    'plugins/instructure_contextmenu/editor_plugin'
    'plugins/instructure_embed/editor_plugin'
    'plugins/instructure_equation/editor_plugin'
    'plugins/instructure_equella/editor_plugin'
    'plugins/instructure_external_tools/editor_plugin'
    'plugins/instructure_links/editor_plugin'
    'plugins/instructure_record/editor_plugin'
  ]

  tinymce

