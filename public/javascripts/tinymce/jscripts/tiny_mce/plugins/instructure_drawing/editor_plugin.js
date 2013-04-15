define([
  'compiled/editor/stocktiny',
  'i18n!editor',
  'jquery',
  'str/htmlEscape',
  'jqueryui/dialog',
  'jquery.instructure_misc_helpers',
  "sketcher"
], function(tinymce, I18n, $) {
  // function isCanvasSupported(){
//     var el = document.creatElement( "canvas" );
//     return el.getContext && el.getContext("2d");
//   }
//   if(!isCanvasSupported)return false;
  var Painter,
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
      appTitle : "画板"

    };
  tinymce.create('tinymce.plugins.' + pluginProp.id,  {
    init : function(ed, url) {
      ed.addCommand(pluginProp.id, function() {
        //console.log(ed.id);
        console.log(ed.selection.getContent());
        sketchSetting.stageId = ed.id + "_" + sketchSetting.sketchType;      // set stageId dynamic

        var $editor = $("#" + ed.id),
          $editorIframe = $("#" + ed.id + "_ifr").contents();
        var parternQuotation = /\"|\'|\)|\(|url/g;

        if( Painter == undefined ) initial();

        var $chosen = $editorIframe.find("img.focused");
        if( !!$chosen.size() ) conveyToBoard();


        Painter.App.dialog({
          width: sketchSetting.canvasW + 60,
          minHeight: sketchSetting.canvasH + 200,
          buttons: { "保存": function() {
            saveImg();
            Painter.clear();
            $(this).dialog("close");
          }},
          title:sketchSetting.appTitle,
          dialogClass: sketchSetting.sketchType,
          "resizable": false,
          close: function() {
            reset();
          }
        });

        function initial(){
          Painter = new Sketcher(sketchSetting);
          Painter.App.find(".tools .line").trigger("click");
        }

        function reset(){
          Painter.clear();
          Painter.canvas.css("background-image","none");
        }

        function conveyToBoard(){
          var drawingData,
            parternPng = /data:image\/png/,
            srcIsData = parternPng.test($chosen.attr("src"));

          if(srcIsData){

            var chosenImgSrc = $chosen.css('background-image');
            var hasBgImg = (chosenImgSrc != "none");
            chosenImgSrc = chosenImgSrc.replace(parternQuotation,'');

            if(hasBgImg){
              Painter.canvas.css( "background", "url(" + chosenImgSrc + ") no-repeat 0 0" );
            }

            // ****** paint canvas
            drawingData = $chosen.attr("src");
            var canvasImage = new Image();
            canvasImage.src = drawingData;
            canvasImage.onload = function() {
              Painter.context.drawImage(this, 0, 0);
            };
            // end

          }else{
            //****** src is normal
            var imgSrc = $chosen[0].src;
            Painter.canvas.css( "background","url(" + imgSrc + ") no-repeat 0 0" );
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
            imageData = Painter.context.getImageData(0, 0, canvasW, canvasH),
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
          var canvasBg = Painter.canvas.css("background-image");

          if( (canvasBg != "none") ){
            canvasBg = canvasBg.replace(parternQuotation,'');
            // edge don't beyond canvas
            var  $bgimg = $("<img>").attr("src",canvasBg)[0],
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
          edge = 1;
          cropWidth = cropRight - cropLeft + edge;
          cropHeight = cropBottom - cropTop + edge;
          $croppedCanvas = $("<canvas>").attr({ width: cropWidth, height: cropHeight });

          $croppedCanvas[0].getContext("2d").drawImage(Painter.canvas[0],
            cropLeft, cropTop, cropWidth, cropHeight,
            0, 0, cropWidth, cropHeight);
          returnObj = {urlData:$croppedCanvas[0].toDataURL(),width:cropWidth,height:cropHeight};

          return returnObj;

        }

        function saveImg(){
          var $div = $("<div></div>"),
            data = removeBlanks(),
            $img = $("<img/>");

          var canvasBg = Painter.canvas.css("background-image");
          var hasBg = canvasBg != "none";
          if(  hasBg ){
            canvasBg = canvasBg.replace(parternQuotation,'');
            var havePreview = canvasBg.indexOf("preview") != -1;
            var size = "width:" + data.width/3 + "px;height:" + data.height/3 + "px;";
            var bgImage = new Image();
            bgImage.src = canvasBg;
            bgImage.onload = function() {
              var style = havePreview ?  "background:url( " + canvasBg + " ) no-repeat;" : "background:url(" + canvasBg + ") no-repeat;";
              style += size;
              style += "background-size:" + bgImage.width/3 +"px;";
              $img.attr({
                "src":data.urlData,
                "data-mce-src":data.urlData,
                "style":style,
                "data-mce-style":style
              });
              $div.append($img);
              $editor.editorBox('insert_code', $div.html());
            };

          } else{
            $img.attr({
              "src": data.urlData
            }).css({
                width:data.width/3
              });
            $div.append($img);
            $editor.editorBox('insert_code', $div.html());
          }
        }

      });

      ed.addButton(pluginProp.name, {
        title: sketchSetting.sketchType,
        cmd: pluginProp.id,
        image: url + '/img/' + sketchSetting.sketchType +'.gif'
      });
    },

    getInfo : function() {
      return {
        longname : pluginProp.id,
        author : 'Rupert.qin',
        authorurl : 'http://www.jiaoxuebang.com',
        infourl : 'http://www.jiaoxuebang.com',
        version : tinymce.majorVersion + "." + tinymce.minorVersion
      };
    }
  });

  // Register plugin
  tinymce.PluginManager.add(pluginProp.name, tinymce.plugins[pluginProp.id]);
});
