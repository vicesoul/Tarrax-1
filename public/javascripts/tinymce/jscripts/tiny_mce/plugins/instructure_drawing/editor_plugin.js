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
        insertType,
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

          var backgroundContainer = $(".img_background");
          var $chosen = $editorBody.find("img.focused");
          if (!!$chosen.length ){
              insertType = "switch";
              var hasEdit = $chosen.hasClass("editted");
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
              }else{
                  insertType = "blank";
                  backgroundContainer.html(""); // **** empty bg img

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

          var removeBlanks = function (imgWidth, imgHeight) {
              console.log("remooveBlank");
              var canvas = $("canvas." + sketcher.defaultSetting.canvasClass)[0];
              var context = canvas.getContext('2d');
              var imageData = context.getImageData(0, 0, imgWidth, imgHeight),
                  data = imageData.data,
                  getRBG = function(x, y) {
                      var offset = imgWidth * y + x;
                      return {
                          red:     data[offset * 4],
                          green:   data[offset * 4 + 1],
                          blue:    data[offset * 4 + 2],
                          opacity: data[offset * 4 + 3]
                      };
                  },
                  isWhite = function (rgb) {
                      // many images contain noise, as the white is not a pure #fff white
                      //return rgb.red > 200 && rgb.green > 200 && rgb.blue > 200;
                      return rgb.opacity == 0;
                  },
                  scanY = function (fromTop) {
                      var offset = fromTop ? 1 : -1;

                      // loop through each row
                      for(var y = fromTop ? 0 : imgHeight - 1; fromTop ? (y < imgHeight) : (y > -1); y += offset) {

                          // loop through each column
                          for(var x = 0; x < imgWidth; x++) {
                              var rgb = getRBG(x, y);
                              if (!isWhite(rgb)) {
                                  return y;
                              }
                          }
                      }
                      return null; // all image is white
                  },
                  scanX = function (fromLeft) {
                      var offset = fromLeft? 1 : -1;

                      // loop through each column
                      for(var x = fromLeft ? 0 : imgWidth - 1; fromLeft ? (x < imgWidth) : (x > -1); x += offset) {

                          // loop through each row
                          for(var y = 0; y < imgHeight; y++) {
                              var rgb = getRBG(x, y);
                              if (!isWhite(rgb)) {
                                  return x;
                              }
                          }
                      }
                      return null; // all image is white
                  };

              var cropTop = scanY(true),
                  cropBottom = scanY(false),
                  cropLeft = scanX(true),
                  cropRight = scanX(false),
                  cropWidth = cropRight - cropLeft,
                  cropHeight = cropBottom - cropTop;

              var $croppedCanvas = $("<canvas>").attr({ width: cropWidth, height: cropHeight });

              // finally crop the guy
              $croppedCanvas[0].getContext("2d").drawImage(canvas,
                  cropLeft, cropTop, cropWidth, cropHeight,
                  0, 0, cropWidth, cropHeight);

              $("body").
                  append($croppedCanvas);
              console.log(cropTop, cropBottom, cropLeft, cropRight);
          };

          function saveImg(Dialog){
              var dataURL = $(".sketch")[0].toDataURL();
              if(insertType == "switch"){

              var originImgSrc = backgroundContainer.find("img")[0].src;


              $chosen
                  .attr({

                      "src":dataURL,
                      "data-mce-src":dataURL

                  })
                  .css({
                      "background":"url(" + originImgSrc + ") no-repeat",
                      "max-width":defaultSetting.canvasW,
                      "min-width":defaultSetting.canvasW,
                      "max-height":defaultSetting.canvasH,
                      "min-height":defaultSetting.canvasH
                  })
                  .addClass("editted");


                  // clone style to data-mce-style
                  var style = $chosen.attr("style");
                  $chosen.attr("data-mce-style",style)

              }else if(insertType == "blank"){

                  var $editor = $("#" + ed.id);
                  var $div = $(document.createElement('div'));
                  var $img = $(document.createElement('img'));
                  $img.attr('src', dataURL);
                  $div.append($img);
                  $editor.editorBox('insert_code', $div.html());
              }
              removeBlanks(600,400);



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

