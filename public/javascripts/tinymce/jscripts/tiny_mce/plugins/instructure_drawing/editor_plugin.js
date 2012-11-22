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
        insertType,
        defaultSetting = {
            container: "",
            canvasClass:"sketch",
            stageId:"",
            lineW : 1,
            canvasW : 600,
            canvasH : 400,
            color : {hex:"000000",rgb:[0,0,0]},
            tools : {type:"line",src:""}

        };

  tinymce.create('tinymce.plugins.InstructureDrawing',  {
    init : function(ed, url) {
      ed.addCommand('instructureDrawing', function() {
        console.log(ed);
      var $editorIframe = $("#" + ed.id + "_ifr").contents(),
          $editorBody = $editorIframe.find("body#tinymce");

        // ****** if first open box
        if($(".drawing_app").length == 0) {
            defaultSetting.stageId = ed.id + "_drawing_container";      // set stageId dynamic
            sketcher = new Sketcher(defaultSetting);
            $('head').append('<link rel="stylesheet" href="' + url + '/css/style.css" type="text/css" />');

              }
        // ****** end

          sketcher.clear();    // reset canvas

          var backgroundContainer = $(".img_background"),
              $chosen = $editorBody.find("img.focused"),
              drawingData,
              canvasImage,
              hasEdit = $chosen.hasClass("editted");

          if (!!$chosen.length && !$chosen.hasClass("blank")){
              insertType = "switch";
                          if(hasEdit){
                              // ******* add background img
                              var originImgSrc = $chosen.css('background-image');

                                  if(originImgSrc != "none"){
                                  var patt=/\"|\'|\)|\(|url/g;
                                  originImgSrc = originImgSrc.replace(patt,'');
                                  var newImg = $("<img/>").attr("src",originImgSrc);

                                  backgroundContainer
                                      .html("")
                                      .append(newImg);
                                  }

                              //*********** add drawing img
                              drawingData = $chosen.attr("src");
                              canvasImage = new Image();
                              canvasImage.src = drawingData;
                              canvasImage.onload = function() {
                                  imageToCanvas(this,sketcher.defaultSetting.canvasClass);
                              };
                          }else{
                              backgroundContainer
                                  .html("")
                                  .append($chosen.clone());
                              }

              }else{
                  insertType = "blank";
                  backgroundContainer.html(""); // **** empty bg img

              if (!!$chosen.length){
              //*********** add drawing img
                  drawingData = $chosen.attr("src");
                  canvasImage = new Image();
                  canvasImage.src = drawingData;
                  canvasImage.onload = function() {
                      imageToCanvas(this,sketcher.defaultSetting.canvasClass);
                  };
              }

              }





          $(".drawing_app").dialog({
              minWidth: 650,
              buttons: { "保存": function() { saveImg( $(this) )} ,"取消": function() { $( this ).dialog( "close" ); } },
              title:"画板",
              dialogClass: "instructure_drawing_prompt"


          });

          function imageToCanvas(imageObj,canvasClass) {
              var context = $("canvas." + canvasClass)[0].getContext('2d');
              context.drawImage(imageObj, 0, 0);
          }

          function removeBlanks(bgw,bgh) {
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
                  cropRight = scanX(false);
              if(bgw){                          // if has the args:type if switch :

                  // edge don't beyond canvas
                  bgw = bgw <= canvasW ? bgw : canvasW;
                  bgh = bgh <= canvasH ? bgh : canvasH;

                  cropRight = cropRight <= bgw ? bgw : cropRight;
                  cropBottom = cropBottom <= bgh ? bgh : cropBottom;

                  // set leftTop point to 0 0
                  cropLeft = 0;
                  cropTop = 0;

              }else{}
               cropWidth = cropRight - cropLeft;
               cropHeight = cropBottom - cropTop;
               $croppedCanvas = $("<canvas>").attr({ width: cropWidth, height: cropHeight });

               $croppedCanvas[0].getContext("2d").drawImage(canvas,
                  cropLeft, cropTop, cropWidth, cropHeight,
                  0, 0, cropWidth, cropHeight);
                returnObj = {urlData:$croppedCanvas[0].toDataURL(),width:cropWidth,height:cropHeight};

              return returnObj;

          }

          function saveImg(Dialog){
              if(insertType == "switch"){
              var  $bgimg = backgroundContainer.find("img"),
                   getData = removeBlanks($bgimg[0].width,$bgimg[0].height),
                   originImgSrc = backgroundContainer.find("img")[0].src,
                   style ="";
                      style += "background:url('" + originImgSrc + "') no-repeat;";
                      style += "max-width:" + getData.width + "px;";
                      style += "min-width:" + getData.width + "px;";
                      style += "max-height:" + getData.height + "px;";
                      style += "min-height:" + getData.height + "px;";


                  $chosen.attr({

                      "src":getData.urlData,
                      "data-mce-src":getData.urlData,
                      "style":style,
                      "data-mce-style":style

                          })
                          .addClass("editted");


              }else if(insertType == "blank"){
                  var $editor = $("#" + ed.id),
                      $div = $(document.createElement('div')),
                      dataURL = removeBlanks().urlData,
                      $img = $("<img/>").attr("src",dataURL).addClass("blank");

                  $div.append($img);
                  $editor.editorBox('insert_code', $div.html());

              }
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

