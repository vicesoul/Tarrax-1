define([
  'compiled/editor/stocktiny',
  'i18n!editor',
  'jquery'
], function(tinymce, I18n, $) {
var flag = false;
  tinymce.create('tinymce.plugins.InstructureAddRackets',  {
    init : function(ed, url) {
      ed.addCommand('instructureAddRackets', function() {

      var $editorIframe = $("#" + ed.id + "_ifr").contents(),
          $editorBody = $editorIframe.find("body#tinymce");

          flag = !flag;
          if(flag){
              $("#quiz_description_instructure_add_rackets").css({
                  "opacity":1
              });
          var count = 0;
          $editorBody.mouseup( function(event) {
              var  $text = ed.selection.getContent();
              if(!$text){
                  return;
                   $text = "blank" + count;
                  count ++;
              }
              $text = "[" + $text + "]";
              var $editor = $("#" + ed.id);
              $editor.editorBox('insert_code', $text);

              flag = true;
          });
          }else{
              $editorBody.unbind("mouseup");
              $("#quiz_description_instructure_add_rackets").css({
                  "opacity":0.5
              });
              flag = false;
          }

      });
      ed.addButton('instructure_add_rackets', {
        title: 'drawing',
        cmd: 'instructureAddRackets',
        image: url + '/img/icon.png'
      });
    },

    getInfo : function() {
      return {
        longname : 'InstructureAddRackets',
        author : 'Rupert.qin',
        authorurl : 'http://www.instructure.com',
        infourl : 'http://www.instructure.com',
        version : tinymce.majorVersion + "." + tinymce.minorVersion
      };
    }
  });

  // Register plugin

tinymce.PluginManager.add('instructure_add_rackets', tinymce.plugins.InstructureAddRackets);
});

