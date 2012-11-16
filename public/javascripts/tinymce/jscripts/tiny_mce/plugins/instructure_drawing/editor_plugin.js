define([
  'compiled/editor/stocktiny',
  'i18n!editor',
  'jquery',
  'str/htmlEscape',
  'jqueryui/dialog',
  'jqueryui/slider',
  'jquery.instructure_misc_helpers',
  "underscore",
   "backbone",
   "kinetic-v4.0.1",
   "modernizr.custom.34982",
   "sketcher",
   "jquery.ui.touch"
], function(tinymce, I18n, $, htmlEscape) {

    var sketcher,
        defaultSetting = {
            container: "",
            canvasClass:"sketch",
            stageId:"",
            lineW : 3,
            canvasW : 600,
            canvasH : 400,
            color : {hex:"000000",rgb:[0,0,0]},
            tools : {type:"line",src:""}

        };

  tinymce.create('tinymce.plugins.InstructureDrawing',  {
    init : function(ed, url) {
      ed.addCommand('instructureDrawing', function() {
        console.log(ed);
      var $editorIframe = $("#" + ed.id + "_ifr").contents();
      var $editorBody = $editorIframe.find("body#tinymce");

        // ****** if first open box
        if($(".drawing_app").length == 0) {
            defaultSetting.stageId = ed.id + "drawing_container";
            sketcher = new Sketcher(defaultSetting);
            $('head').append('<link rel="stylesheet" href="' + url + '/css/style.css" type="text/css" />');

              }
        // ****** end


          sketcher.clear();    // reset canvas

          var $chosen = $editorBody.find("img.focused");
          var hasEdit = $chosen.hasClass("editted");
          var backgroundContainer = $(".img_background");

          if(hasEdit){
              // ******* add background img
              var originImgSrc = $chosen.css('background-image');
              var patt=/\"|\'|\)|\(|url/g;
                  originImgSrc = originImgSrc.replace(patt,'');
              var newImg = $("<img/>").attr("src",originImgSrc);
                  backgroundContainer
                      .html("")
                      .append(newImg);

              //*********** add drawing img
              var drawingData = $chosen.attr("src");
              var imageObj = new Image();
              imageObj.src = drawingData;
              imageObj.onload = function() {
                  drawImage(this,sketcher.defaultSetting.canvasClass);
              };
          }else{
              backgroundContainer
                  .html("")
                  .append($chosen.clone());
          }

          $(".drawing_app").dialog({
              minWidth: 650,
              minHeight:700,
              buttons: { "保存": function() { saveImg( $(this) )} ,"取消": function() { $( this ).dialog( "close" ); } },
              title:"画板",
              dialogClass: "instructure_drawing_prompt"


          });

          function drawImage(imageObj,canvasClass) {
              var canvas = $("canvas." + canvasClass)[0];
              var context = canvas.getContext('2d');
              var imageX = 0;
              var imageY = 0;
              var imageWidth = imageObj.width;
              var imageHeight = imageObj.height;

              context.drawImage(imageObj, imageX, imageY);

              /*            var imageData = context.getImageData(imageX, imageY, imageWidth, imageHeight);
               var data = imageData.data;


               for(var i = 0, n = data.length; i < n; i += 4) {
               var red = data[i];
               var green = data[i + 1];
               var blue = data[i + 2];
               var alpha = data[i + 3];
               }

               for(var y = 0; y < sourceHeight; y++) {

               for(var x = 0; x < sourceWidth; x++) {
               var red = data[((sourceWidth * y) + x) * 4];
               var green = data[((sourceWidth * y) + x) * 4 + 1];
               var blue = data[((sourceWidth * y) + x) * 4 + 2];
               var alpha = data[((sourceWidth * y) + x) * 4 + 3];
               }
               }


               context.putImageData(imageData, imageX, imageY);*/
          }

          function canvasToCanvas(origin,target){
              var origin_canvas = $("#" + origin)[0];
              var origin_context = origin_canvas.getContext('2d');

              var target_canvas = $("#" + target)[0];
              var target_context = target_canvas.getContext('2d');

              var Width = 600;
              var height =400;

              var imageData = origin_context.getImageData(0, 0, Width, height);
              target_context.putImageData(imageData, 0, 0);

          }


          function saveImg(Dialog){
              var dataURL = $(".sketch")[0].toDataURL();
              var originImgSrc = backgroundContainer.find("img")[0].src;


              $chosen
                  .attr({
                      "src":dataURL
                  })
                  .css({
                      "background":"url(" + originImgSrc + ") no-repeat",
                      "max-width":defaultSetting.canvasW,
                      "min-width":defaultSetting.canvasW,
                      "max-height":defaultSetting.canvasH,
                      "min-height":defaultSetting.canvasH
                  })
                  .addClass("editted");



              Dialog.dialog( "close" );

          }

      });
      ed.addButton('instructure_drawing', {
        title: 'drawing',
        cmd: 'instructureDrawing',
        image: url + '/img/drawing.gif'
      });
    },

    getInfo : function() {
      return {
        longname : 'InstructureDrawing',
        author : 'Rupert.qin',
        authorurl : 'http://www.instructure.com',
        infourl : 'http://www.instructure.com',
        version : tinymce.majorVersion + "." + tinymce.minorVersion
      };
    }
  });

  // Register plugin

tinymce.PluginManager.add('instructure_drawing', tinymce.plugins.InstructureDrawing);
});

