define [
  'vendor/underscore'
  'tinymce/jscripts/tiny_mce/tiny_mce_src'
  'sketcher'
], () ->

  module 'tinymce'
  test 'version', ->
    version = tinyMCE.majorVersion
    equal version, '3'

  test 'sketcher', ->
    sketchSetting =
      sketchType:"paint"
      stageId:""
      lineW : 1
      canvasW : 600
      canvasH : 400
      color :
        hex: "000000"
        rgb: [0,0,0]
      tools :
        type: "line"
        src: ""
      appName : "sketch_app"
      appTitle : "画板"

    Painter = new Sketcher(sketchSetting);
    equal Painter.get("lineW"), 1, "we expect lineW to be 1px"
    equal Painter.get("canvasW"), '600', "we expect canvasW to be 600px"
    equal $("canvas.canvasDraft").size() , 1, "we expect canvasDraft to be generated"