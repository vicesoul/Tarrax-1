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
          $editor = $("#" + ed.id),
          $question = $editor.closest(".question_holder ").find(".question");


      var $icon = $("#" + ed.id + "_instructure_add_rackets");

          addRackets = !addRackets;
          if(addRackets){
              addRackets = true;
              $icon.css({
                  "opacity":1
              });

          $editorBody.bind("mouseup",addRacket);

          }else{
              addRackets = false;

              $icon.css({
                  "opacity":0.5
              });
              $editorBody.unbind("mouseup");
              
          }

          function checkChinese(str){  
              var reg=/[\u4E00-\u9FA5]/g;
              return(reg.test(str));
            }

          function addRacket() {
              var  selectedText = ed.selection.getContent();
              if($question.is(".calculated_question")){
                  if(!selectedText || checkChinese(selectedText)){return;}
                  $editor.editorBox('insert_code', "[" + selectedText + "]");
              }else if($question.is(".fill_in_multiple_blanks_question")){
                  //*** var this term before insert_code,coz after insert_code this element will be remove
                  var hasOption = !!$question.find(".multi_answer_sets .blank_id_select .shown_when_no_other_options_available").size();
                  //*** end

                  //*** if .form_answers is not empty, when select change(), the possible answer is not appendTo, so the input will not be put in text
                  if(hasOption){
                      $question.find(".form_answers").html("");
                  }
                  //*** end

                  var editorText = $editor.editorBox('get_code');
                  var matches = editorText.match(/\[blank[0-9]*\]/g);

                  var count = 1;
                  if(matches != null){
                  $.each(matches,function(i){
                      var thisNum = matches[i].match(/\d{1,4}/)[0];
                          thisNum = Number(thisNum);
                      count = count < thisNum ? thisNum : count;


                  });
                      count ++;
                     }

                  var  text = "blank" + count;



                  $editor.editorBox('insert_code', "[" + text + "]");


                  if(hasOption){

                      $question.find(".form_answers .short_answer:first input").val(selectedText);

                  }else{

                  //*** convey the text to select box, why use setTimeout? the editor check the changes every 200ms
                  setTimeout(function(){
                      $question.find(".blank_id_select option[value=" + text + "]").attr("data-text",selectedText);
                  },300);
                  //*** end

                  }



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

