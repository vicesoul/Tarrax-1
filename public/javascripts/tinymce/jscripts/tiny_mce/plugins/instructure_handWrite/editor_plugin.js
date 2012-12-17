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
], function(tinymce, I18n, $) {

    var HandWrite,
        pluginProp = {id:"instructureHandWrite",name:"instructure_handWrite"},
        defaultSetting = {  
            sketchType:"handWrite",
            stageId:"",
            lineW : 10,
            canvasW : 1000,
            canvasH : 240,
            color : {hex:"000000",rgb:[0,0,0]},
            tools : {type:"line",src:""},
            appName : "sketch_app",
            appTitle : "写字板"

        };

  tinymce.create('tinymce.plugins.' + pluginProp.id,  {
    init : function(ed, url) {
      ed.addCommand(pluginProp.id, function() {
      var $editor = $("#" + ed.id),
          $editorIframe = $("#" + ed.id + "_ifr").contents(),
          dialogStr = '.' + defaultSetting.appName + '.' + defaultSetting.sketchType,
          writeState;

          defaultSetting.stageId = ed.id + "_" + defaultSetting.sketchType;      // set stageId dynamic

          function init(){
              HandWrite = new Sketcher(defaultSetting);

              if(!$("#handWriteCopy").size()){
                  $("<canvas></canvas>")
                      .attr({
                          width:defaultSetting.canvasW/8,
                          height:defaultSetting.canvasH/8,
                          id:"handWriteCopy"
                      })
                      .appendTo("body");
              }
              HandWrite.brushSize = {width:9,height:9,step:.3};
              $(".big_brush").trigger("click");
              var touchSupported = Modernizr.touch,
                  mouseDownEvent,
                  mouseMoveEvent,
                  mouseUpEvent;

              if (touchSupported) {
                  mouseDownEvent = "touchstart";
                  mouseMoveEvent = "touchmove";
                  mouseUpEvent = "touchend";
              }else {
                  mouseDownEvent = "mousedown";
                  mouseMoveEvent = "mousemove";
                  mouseUpEvent = "mouseup";
              }

              var $writingCanvas = $(dialogStr).find("." + defaultSetting.sketchType);
              var checkWriteDone;

              $writingCanvas.bind(mouseDownEvent,function(){
                  writeState = true;
                  clearTimeout(checkWriteDone);
              });

              $(document).bind(mouseUpEvent,function(){
                  checkWriteDone = setTimeout(function(){
                      saveImg();
                      writeState = false;
                  },500);

              });

          }

          if(!$(dialogStr).size()) { init();}// ****** if first open box

          $(dialogStr).dialog({
              width:"100%",
              minHeight:$(window).height(),
              title:defaultSetting.appTitle,
              dialogClass: defaultSetting.sketchType,
              "resizable": false,
              modal: true,
              close: function() {
                      HandWrite.clear();             // **** empty canvas
              }

          });

          function removeBlanks(canvasTarget) {
           var canvasW = defaultSetting.canvasW,
               canvasH = defaultSetting.canvasH,
               cropWidth,
               cropHeight,
               returnObj,
               $croppedCanvas,
               canvas = $(canvasTarget)[0],
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

              var cropTop = 0,
                  cropBottom = scanY(false),
                  cropLeft = scanX(true),
                  cropRight = scanX(false),
                  edge = 1;

               cropWidth = cropRight - cropLeft + edge;
               cropHeight = defaultSetting.canvasH/8;
               $croppedCanvas = $("<canvas>").attr({ width: cropWidth, height: cropHeight });

               $croppedCanvas[0].getContext("2d").drawImage(canvas,
                  cropLeft, cropTop, cropWidth, cropHeight,
                  0, 0, cropWidth, cropHeight);
                returnObj = {urlData:$croppedCanvas[0].toDataURL(),width:cropWidth,height:cropHeight};

              return returnObj;

          }

          function saveImg(){
              var handWriteData = $(dialogStr).find("." + defaultSetting.sketchType).get(0).toDataURL();
              var $copy = $("#handWriteCopy");
              var copyContext = $copy[0].getContext('2d');
              var canvasImage = new Image();
                  canvasImage.src = handWriteData;
                  canvasImage.onload = function() {
                  copyContext.drawImage(this, 0, 0,defaultSetting.canvasW/8,defaultSetting.canvasH/8);
                      var $div = $(document.createElement('div')),
                          data = removeBlanks($copy),
                          $img = $("<img/>").attr("src",data.urlData).addClass(defaultSetting.sketchType);


                      $div.append($img);
                      $editor.editorBox('insert_code', $div.html());

                      // **** clear canvas
                      HandWrite.clear();
                      copyContext.clearRect( 0, 0,defaultSetting.canvasW/8,defaultSetting.canvasH/8);
                      // end

              };
          }

      });

      ed.addButton(pluginProp.name, {
        title: defaultSetting.sketchType,
        cmd: pluginProp.id,
        image: url + '/img/' + defaultSetting.sketchType +'.png'
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

