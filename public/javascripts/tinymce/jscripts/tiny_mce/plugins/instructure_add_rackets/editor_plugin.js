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
          $editorBody = $editorIframe.find("body#tinymce"),
          $question = $("#" + ed.id).closest(".question_holder ").find(".question");

      var $icon = $("#" + ed.id + "_instructure_add_rackets");
          addRackets = !addRackets;
          if(addRackets){
              addRackets = true;
              $icon.css({
                  "opacity":1
              });
          var count = 0;
          $editorBody.bind("mouseup",addRacket);

          }else{
              addRackets = false;

              $icon.css({
                  "opacity":0.5
              });
              $editorBody.unbind("mouseup");

          }
          function addRacket() {
              var  selectedText = ed.selection.getContent();
              if(!selectedText){
                  return;
              }
              var $editor = $("#" + ed.id);
              if($question.is(".calculated_question")){
                  $editor.editorBox('insert_code', "[" + selectedText + "]");
              }else if($question.is(".fill_in_multiple_blanks_question")){

                  var  text = "blank" + count;
                  count ++;
                  $editor.editorBox('insert_code', "[" + text + "]");

                  //*** convey the text to select box, why use setTimeout? the editor check the changes every 200ms
                  setTimeout(function(){
                      $question.find(".blank_id_select ." + text).attr("data-text",selectedText);
                  },500);
                  //*** end

              }
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

