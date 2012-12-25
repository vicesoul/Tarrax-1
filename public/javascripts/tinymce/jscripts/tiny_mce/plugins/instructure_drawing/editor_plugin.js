define([
  'compiled/editor/stocktiny',
  'i18n!editor',
  'jquery',
  'str/htmlEscape',
  'jqueryui/dialog',
  'jqueryui/slider',
  'jquery.instructure_misc_helpers',
   "modernizr.custom.34982",
   "sketcher",
   "jquery.ui.touch"
], function(tinymce, I18n, $) {
    var sketcher,
        pluginProp = {id:"instructure_drawing",name:"instructure_drawing"},
        sketchSetting = {
            sketchType:"paint",
            stageId:"",
            lineW : 1,
            canvasW : 600,
            canvasH : 400,
            color : {hex:"000000",rgb:[0,0,0]},
            tools : {type:"line",src:""},
            appName : "sketch_app",
            appTitle : "画板",
            savePaint : new Function()

        };
  tinymce.create('tinymce.plugins.' + pluginProp.id,  {
    init : function(ed, url) {
      ed.addCommand(pluginProp.id, function() {
        //console.log(ed);
        //console.log(ed.selection.getContent());
      sketchSetting.stageId = ed.id + "_" + sketchSetting.sketchType;      // set stageId dynamic

      var $editor = $("#" + ed.id),
          $editorIframe = $("#" + ed.id + "_ifr").contents(),
          dialogStr = '.' + sketchSetting.appName + '.' + sketchSetting.sketchType,
          backgroundContainer = dialogStr + " .img_background",
          writingCanvasStr = dialogStr + " " + "canvas." + sketchSetting.sketchType,
          $writingCanvas;

        //****** if first open box
        if(!$(dialogStr).size()) {
            sketcher = new Sketcher(sketchSetting);
        }

          conveyToBoard();

          $(dialogStr).dialog({
              //minWidth: sketcher.sketchSetting.canvasW + 26,
              width:"100%",
              minHeight:$(window).height(),
              buttons: { "保存": function() {
                  saveImg();
                  sketcher.reset();
                  $(this).dialog("close");
              }},
              title:sketchSetting.appTitle,
              dialogClass: sketchSetting.sketchType,
              "resizable": false,
              close: function() {

                      // **** empty canvas & bg img
                      sketcher.clear();
                      $(backgroundContainer).html("");
                        // end

                    }

          });

          function conveyToBoard(){
              var $chosen = $editorIframe.find("img.focused"),
                  drawingData,
                  parternPng = /data:image\/png/,
                  parternQuotation = /\"|\'|\)|\(|url/g,
                  srcIsData = parternPng.test($chosen.attr("src")),
                  chosenImgSrc = $chosen.css('background-image');

              if(srcIsData){
              var hasBgImg = !(chosenImgSrc == undefined || chosenImgSrc == "none");
                  if(hasBgImg){

                      // ******* load background img
                      chosenImgSrc = chosenImgSrc.replace(parternQuotation,'');
                      var newImg = $("<img/>").attr({
                          "src":chosenImgSrc,
                          "data-mce-src":chosenImgSrc
                      });
                      $(backgroundContainer).append(newImg);
                        // end
                  }

                  // ****** paint canvas
                  drawingData = $chosen.attr("src");
              var canvasImage = new Image();
                  canvasImage.src = drawingData;
                  canvasImage.onload = function() {
                      var context = $("canvas." + sketchSetting.sketchType)[0].getContext('2d');
                      context.drawImage(this, 0, 0);
                  };
                  // end

              }else{
                  //****** src is normal
                  $(backgroundContainer).append($chosen.clone());
                  // end
              }
          }

          function removeBlanks() {
           var canvasW = sketchSetting.canvasW,
               canvasH = sketchSetting.canvasH,
               cropWidth,
               cropHeight,
               returnObj,
               $croppedCanvas,
               canvas = $("canvas." + sketcher.Setting.sketchType)[0],
               context = canvas.getContext('2d'),
               imageData = context.getImageData(0, 0, canvasW, canvasH),
               data = imageData.data,
               getRBG = function(x, y) {
                      var offset = canvasW * y + x;
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
                  for(var y = fromTop ? 0 : canvasH - 1; fromTop ? (y < canvasH) : (y > -1); y += offset) {

                      // loop through each column
                      for(var x = 0; x < canvasW; x++) {
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
                  for(var x = fromLeft ? 0 : canvasW - 1; fromLeft ? (x < canvasW) : (x > -1); x += offset) {

                      // loop through each row
                      for(var y = 0; y < canvasH; y++) {
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
                  edge = 0;
              if(!!$(backgroundContainer).find("img").size()){
                  // edge don't beyond canvas
                  var  $bgimg = $(backgroundContainer).find("img")[0],
                       bgw = $bgimg.width,
                       bgh = $bgimg.height;
                  bgw = bgw <= canvasW ? bgw : canvasW;
                  bgh = bgh <= canvasH ? bgh : canvasH;

                  cropRight = cropRight <= bgw ? bgw : cropRight;
                  cropBottom = cropBottom <= bgh ? bgh : cropBottom;

                  // set leftTop point to 0 0
                  cropLeft = 0;
                  cropTop = 0;

              }else {
                  edge = 1;
              }
               cropWidth = cropRight - cropLeft + edge;
               cropHeight = cropBottom - cropTop + edge;
               $croppedCanvas = $("<canvas>").attr({ width: cropWidth, height: cropHeight });

               $croppedCanvas[0].getContext("2d").drawImage(canvas,
                  cropLeft, cropTop, cropWidth, cropHeight,
                  0, 0, cropWidth, cropHeight);
                returnObj = {urlData:$croppedCanvas[0].toDataURL(),width:cropWidth,height:cropHeight};

              return returnObj;

          }

          function saveImg(){
            var $div = $("<div></div>"),
                data = removeBlanks().urlData,
                $img = $("<img/>");

              if(!!$(backgroundContainer).find("img").size()){


               var originImgSrc = $(backgroundContainer).find("img").attr("data-mce-src") || $(backgroundContainer).find("img").attr("src"),
                   havePreview = originImgSrc.indexOf("preview") != -1,
                   style ="";
                      style += havePreview ?  "background:url( " + originImgSrc + " ) no-repeat;" : "background:url(" + originImgSrc + ") no-repeat;";
    /*                      style += "max-width:" + data.width + "px;";
                      style += "min-width:" + data.width + "px;";
                      style += "max-height:" + data.height + "px;";
                      style += "min-height:" + data.height + "px;";*/

                   $img.attr({  "src":data,
                                "data-mce-src":data,
                                "style":style,
                                "data-mce-style":style
                                });
                   }else{

                      $img.attr("src",data);
                       }
              $div.append($img);
              $editor.editorBox('insert_code', $div.html());
          }

      });

      ed.addButton(pluginProp.name, {
        title: sketchSetting.sketchType,
        cmd: pluginProp.id,
        image: url + '/img/' + sketchSetting.sketchType +'.png'
      });
    },

    getInfo : function() {
      return {
        longname : pluginProp.id,
        author : 'Rupert.qin',
        authorurl : 'http://www.instructure.com',
        infourl : 'http://www.instructure.com',
        version : tinymce.majorVersion + "." + tinymce.minorVersion
      };
    }
  });

  // Register plugin
tinymce.PluginManager.add(pluginProp.name, tinymce.plugins[pluginProp.id]);
});