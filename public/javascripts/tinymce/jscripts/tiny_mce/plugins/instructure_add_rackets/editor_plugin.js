define([
  'compiled/editor/stocktiny',
  'i18n!editor',
  'jquery',
  'jqueryui/position'
], function(tinymce, I18n, $) {
var addRackets = false;
  tinymce.create('tinymce.plugins.InstructureAddRackets',  {
    init : function(ed, url) {
      ed.addCommand('instructureAddRackets', function() {

      var $editorIframe = $("#" + ed.id + "_ifr").contents(),
          $editorIframeSelf = $("#" + ed.id + "_ifr"),
          $editorBody = $editorIframe.find("body#tinymce"),
          $editor = $("#" + ed.id),
          $icon = $("#" + ed.id + "_instructure_add_rackets");


          addRackets = !addRackets;
          if($("#bracketTip").size() == 0){
            var $cube = $("<div id='bracketTip' style='width: 30px;height: 30px; background: green;z-index: 1001;display: none;position: absolute;'></div>").appendTo("body")
          }

          var bracketTip = function (event){
            var marginLeft = 0;
            var marginTop = 0;
            if($(this).find("body").is("#tinymce")){
              var position = $editorIframeSelf.parent(".mceIframeContainer").offset();
              marginLeft = position.left;
              marginTop= position.top;
            }
            $("#bracketTip").css({
              left: event.pageX + marginLeft + 10,
              top: event.pageY + marginTop
            });
          };

          $editorBody.on("mouseenter.bracketBody", function(){
            $("#bracketTip").show()
          })
          $editorBody.on("mouseleave.bracketBody", function(){
            $("#bracketTip").hide()
          })
          if(addRackets){
              addRackets = true;
              $icon.css({
                  "opacity":1
              });

              $editorBody.on("mouseup",addRacket);

              $("#bracketTip").show();
              $editorIframe.on("mousemove.bracket", bracketTip);
          }else{
              addRackets = false;

              $icon.css({
                  "opacity":0.5
              });
              $editorBody.off("mouseup");

              $("#bracketTip").hide();
              $editorIframe.off(".bracketBody");
              $editorBody.off(".bracketBody");

          }

          

          function checkChinese(str){  
              var reg=/[\u4E00-\u9FA5]/g;
              return(reg.test(str));
            }

          function addRacket() {
              var selectedText = ed.selection.getContent();
              var $question = $editor.closest(".question_holder ").find(".question:not(.display_question)");
              if($question.is(".calculated_question")){
                  if(!selectedText || checkChinese(selectedText)){return;}
                  $editor.editorBox('insert_code', "[" + selectedText + "]");
              }else if( $question.is(".fill_in_multiple_blanks_question") 
                || $question.is(".multiple_dropdowns_question")
                || $question.is(".fill_in_blanks_subjective_question")
                ){
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
        authorurl : 'http://www.jiaoxuebang.com',
        infourl : 'http://www.jiaoxuebang.com',
        version : tinymce.majorVersion + "." + tinymce.minorVersion
      };
    }
  });

  // Register plugin

tinymce.PluginManager.add('instructure_add_rackets', tinymce.plugins.InstructureAddRackets);
});

