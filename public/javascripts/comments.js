define([
    'INST' /* INST */,
    'i18n!gradebook',
    'jquery' /* $ */,
    'str/htmlEscape',
    'jqueryui/dialog',
    'jqueryui/slider',
    'jquery.instructure_misc_helpers',
    "kinetic-v4.0.1",
    "modernizr.custom.34982",
    "sketcher"
], function(INST, I18n, $) {
    $(document).ready(function(){
      var $question  = $("#questions"),
          $question_holder  = $(".question_holder"),
          offset = $question.offset(),
          qWidth = $question.width(),
          qHeight = $question.height(),
          sketcher,
          sketchSetting = {
              sketchType:"comment",
              stageId:"comment",
              lineW : 1,
              canvasW : 0,
              canvasH : 0,
              color : {hex:"000000",rgb:[0,0,0]},
              tools : {type:"line",src:""},
              appName : "sketch_app"
          },
          dialogStr = '.' + sketchSetting.appName + '.' + sketchSetting.sketchType;

      var InitHTML = "<div class='comment_menu'>";
          InitHTML += "<input type='button' class='start_drawing' value='Draw'>";
          InitHTML += "<input type='button' class='high_light' value='Highlight'>";
          InitHTML += "</div>";
          $(InitHTML).appendTo($question);

      var drawingState = false;
      $(".start_drawing").click(function(){

          // ****** if first open box
          if($(dialogStr).size() == 0) {initApp();}
          // end

          else{
              $(dialogStr).removeClass("ghost");
          }

      });


      var isLocal = location.host === "lvh.me:3000";

      if (!isLocal){
        $(".comment_menu,.sketch_app").hide();

      } else {
        $(".start_drawing").trigger("click");
        $(".high_light").trigger("click");
      }

      function initApp(){
          sketchSetting.canvasW = qWidth;
          sketchSetting.canvasH = qHeight;
          sketcher = new Sketcher(sketchSetting);
          $(dialogStr).appendTo($question);
          $(".high_light").click(function(){
              $(dialogStr).addClass("ghost");
              highLight();
          });
      }


      function insertHtmlAfterSelection(html) {
          var sel, range, expandedSelRange, node;
          if (window.getSelection) {
              sel = window.getSelection();
              if (sel.getRangeAt && sel.rangeCount) {
                  range = window.getSelection().getRangeAt(0);
                  expandedSelRange = range.cloneRange();
                  range.collapse(false);

                  // Range.createContextualFragment() would be useful here but is
                  // non-standard and not supported in all browsers (IE9, for one)
                  var el = document.createElement("div");
                  el.innerHTML = html;
                  var frag = document.createDocumentFragment(), node, lastNode;
                  while ( (node = el.firstChild) ) {
                      lastNode = frag.appendChild(node);
                  }
                  range.insertNode(frag);

                  // Preserve the selection
                  if (lastNode) {
                      expandedSelRange.setEndAfter(lastNode);
                      sel.removeAllRanges();
                      sel.addRange(expandedSelRange);
                  }
              }
          } else if (document.selection && document.selection.createRange) {
              range = document.selection.createRange();
              expandedSelRange = range.duplicate();
              range.collapse(false);
              range.pasteHTML(html);
              expandedSelRange.setEndPoint("EndToEnd", range);
              expandedSelRange.select();
          }
      }





      function highLight(){
          $($question).delegate($question_holder,"mouseup",function(){
//                var getCode = window.getSelection() || document.selection.createRange().text;

              var getCode = getSelectionHtml();
              console.log(getCode);

          })
      }

      function getSelectionHtml() {
          var html = "";
          if (typeof window.getSelection != "undefined") {
              var sel = window.getSelection();
              if (sel.rangeCount) {
                  var container = document.createElement("div");
                  for (var i = 0, len = sel.rangeCount; i < len; ++i) {
                      container.appendChild(sel.getRangeAt(i).cloneContents());
                  }
                  html = container.innerHTML;
              }
          } else if (typeof document.selection != "undefined") {
              if (document.selection.type == "Text") {
                  html = document.selection.createRange().htmlText;
              }
          }
          return html;
      }

      function initCanvas(){

          $("<canvas></canvas>").attr({
              width:qWidth,
              height:qHeight
          })
              .addClass("sketch")
              .appendTo($question);

          if(drawingState){
              $(document).unbind("mousedown");
              drawingState = false;
          }else{
              $(document).bind("mousedown",downHandle());
              drawingState = true;
          }
      }

      function downHandle(){
          return function(e){
              line = paper.path();
              line.attr("stroke", "#ff6600");
              pathArray = ["M",e.pageX-offset.left,e.pageY-offset.top];
              $(this).bind("mousemove",moveHandle())

          }
      }

      function moveHandle(){
          return function(e){
              pathArray.push(e.pageX-offset.left,e.pageY-offset.top);
              line.attr("path",pathArray);

          }
      }

      $(document).mouseup(function(){
          $(this).unbind("mousemove");
      })


    })




});