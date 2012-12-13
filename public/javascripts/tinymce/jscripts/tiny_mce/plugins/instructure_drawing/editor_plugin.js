define([
  'compiled/editor/stocktiny',
  'i18n!editor',
  'jquery',
  'str/htmlEscape',
  'jqueryui/dialog',
  'jqueryui/slider',
  'jquery.instructure_misc_helpers',
   "kinetic-v4.0.1",
   "modernizr.custom.34982",
   "sketcher",
   "jquery.ui.touch"
], function(tinymce, I18n, $, htmlEscape) {

    var sketcher,
        pluginProp = {id:"instructure_drawing",name:"instructure_drawing"},
        defaultSetting = {
            canvasClass:"paint",
            stageId:"",
            lineW : 1,
            canvasW : 600,
            canvasH : 400,
            color : {hex:"000000",rgb:[0,0,0]},
            tools : {type:"line",src:""},
            appName : "sketch_app",
            appTitle : "画板"

        };

  tinymce.create('tinymce.plugins.' + pluginProp.id,  {
    init : function(ed, url) {
      ed.addCommand(pluginProp.id, function() {
        console.log(ed);
        console.log(ed.selection.getContent());
      var $editor = $("#" + ed.id),
          $editorIframe = $("#" + ed.id + "_ifr").contents(),
          $editorBody = $editorIframe.find("body#tinymce"),
          dialogStr = '.' + defaultSetting.appName + '.' + defaultSetting.canvasClass,
          $bgimg;

          defaultSetting.stageId = ed.id + "_" + defaultSetting.canvasClass;      // set stageId dynamic

        // ****** if first open box
        if(!$(dialogStr).size()) {
            sketcher = new Sketcher(defaultSetting);
            //$('head').append('<link rel="stylesheet" href="' + url + '/css/style.css" type="text/css" />');
              }
        // ****** end

          var backgroundContainer = $(".img_background"),
              $chosen = $editorBody.find("img.focused"),
              drawingData,
              canvasImage,
              parternPng = /data:image\/png/,
              parternQuotation = /\"|\'|\)|\(|url/g,
              srcIsData = parternPng.test($chosen.attr("src")),
              originImgSrc = $chosen.css('background-image'),
              hasBgImg = !(originImgSrc == undefined || originImgSrc == "none"),
              newImg;


          //********* put element to drawing board
              if(srcIsData){                        //*** src is data

                  if(hasBgImg){                     //*** src is data & bgimg

                    // ******* load background img
                    originImgSrc = originImgSrc.replace(parternQuotation,'');
                    newImg = $("<img/>").attr({
                        "src":originImgSrc,
                        "data-mce-src":originImgSrc
                    });
                    backgroundContainer.append(newImg);

                    }

                    // ****** paint canvas
                    drawingData = $chosen.attr("src");
                    canvasImage = new Image();
                    canvasImage.src = drawingData;
                    canvasImage.onload = function() {
                        imageToCanvas(this,sketcher.defaultSetting.canvasClass);
                    };


                }else{                               //*** src is normal
                  backgroundContainer.append($chosen.clone());
                };
        //********** end

          $(dialogStr).dialog({
              //minWidth: sketcher.defaultSetting.canvasW + 26,
              width:"100%",
              minHeight:$(window).height(),
              buttons: { "保存": function() { saveImg();$(this).dialog("close");}},
              title:defaultSetting.appTitle,
              dialogClass: defaultSetting.canvasClass,
              "resizable": false,
              close: function( event, ui ) {
                      sketcher.clear();             // **** empty canvas
                      backgroundContainer.html(""); // **** empty bg img
                    }

          });

          function imageToCanvas(imageObj,canvasClass) {
              var context = $("canvas." + canvasClass)[0].getContext('2d');
              context.drawImage(imageObj, 0, 0);
          }

          function removeBlanks() {
           var canvasW = defaultSetting.canvasW,
               canvasH = defaultSetting.canvasH,
               cropWidth,
               cropHeight,
               returnObj,
               $croppedCanvas,
               canvas = $("canvas." + sketcher.defaultSetting.canvasClass)[0],
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
              if(!!backgroundContainer.find("img").size()){
                  // edge don't beyond canvas
                  $bgimg = backgroundContainer.find("img");
                  var bgw = $bgimg[0].width,
                      bgh = $bgimg[0].height;
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
            var $div = $(document.createElement('div')),
                data = removeBlanks(),
                $img; 

              if(!!backgroundContainer.find("img").size()){
                   
               var originImgSrc = backgroundContainer.find("img").attr("data-mce-src") || backgroundContainer.find("img").attr("src"),
                   havePreview = originImgSrc.indexOf("preview") != -1,
                   style ="";
                      style += havePreview ?  "background:url( " + originImgSrc + " ) no-repeat;" : "background:url(" + originImgSrc + ") no-repeat;";
                      style += "max-width:" + data.width + "px;";
                      style += "min-width:" + data.width + "px;";
                      style += "max-height:" + data.height + "px;";
                      style += "min-height:" + data.height + "px;";
                      $img = $("<img/>")
                              .attr({
                                    "src":data.urlData,
                                    "data-mce-src":data.urlData,
                                    "style":style,
                                    "data-mce-style":style
                                })
                              .addClass("editted");
                   }else{
                        $img = $("<img/>").attr("src",data.urlData);
                       }
              $div.append($img);
              $editor.editorBox('insert_code', $div.html());
          }

      });
      ed.addButton(pluginProp.name, {
        title: defaultSetting.canvasClass,
        cmd: pluginProp.id,
        image: url + '/img/' + defaultSetting.canvasClass +'.png'
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

