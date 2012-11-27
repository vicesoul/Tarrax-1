define([
  'compiled/editor/stocktiny',
  'i18n!editor',
  'jquery'
], function(tinymce, I18n, $) {
var addRackets = false;
  tinymce.create('tinymce.plugins.InstructureAddRackets',  {
    init : function(ed, url) {
      ed.addCommand('instructureAddRackets', function() {

      var $editorIframe = $("#" + ed.id + "_ifr").contents(),
          $editorBody = $editorIframe.find("body#tinymce");

      var $icon = $("#" + ed.id + "_instructure_add_rackets");
          addRackets = !addRackets;
          if(addRackets){
              $icon.css({
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

              addRackets = true;
          });
          }else{
              $editorBody.unbind("mouseup");
              $icon.css({
                  "opacity":0.5
              });
              addRackets = false;
          }

      });
      ed.addButton('instructure_add_rackets', {
        title: 'add rackets to text',
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

