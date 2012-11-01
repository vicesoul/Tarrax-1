define([
  'compiled/editor/stocktiny',
  'i18n!editor',
  'jquery',
  'str/htmlEscape',
  'jqueryui/dialog',
  'jquery.instructure_misc_helpers'
], function(tinymce, I18n, $, htmlEscape) {

  tinymce.create('tinymce.plugins.InstructureDrawing',  {


    init : function(ed, url) {
      
        

      ed.addCommand('instructureDrawing', function() {
        console.log(ed)
        var $editorIframe = $("#" + ed.id + "_ifr").contents();
        var $editorBody = $editorIframe.find("body#tinymce");
        //console.log($editor)

      
        $editorIframe.find('head').append('<link rel="stylesheet" href="' + url + '/css/style.css" type="text/css" />');
        $("<canvas id='drawing_canvas' contenteditable='false'></canvas>").appendTo($editorBody).bind("click",function(){
          alert("ok")
        });

      });
      ed.addButton('instructure_drawing', {
        title: 'Record/Upload Media',
        cmd: 'instructureDrawing',
        image: url + '/img/drawing.gif'
      });
    },

    getInfo : function() {
      return {
        longname : 'InstructureDrawing',
        author : 'Rupert',
        authorurl : 'http://www.instructure.com',
        infourl : 'http://www.instructure.com',
        version : tinymce.majorVersion + "." + tinymce.minorVersion
      };
    }
  });

  // Register plugin

tinymce.PluginManager.add('instructure_drawing', tinymce.plugins.InstructureDrawing);
});

