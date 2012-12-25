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

    var HandWrite,
        pluginProp = {id:"instructureHandWrite",name:"instructure_handWrite"},
        sketchSetting = {  
            sketchType:"handWrite",
            stageId:"",
            lineW : 10,
            canvasW : 1000,
            canvasH : 240,
            color : {hex:"000000",rgb:[0,0,0]},
            tools : {type:"line",src:""},
            appName : "sketch_app",
            appTitle : "写字板",
            saveImage : {}
        };

  tinymce.create('tinymce.plugins.' + pluginProp.id,  {
    init : function(ed, url) {
      ed.addCommand(pluginProp.id, function() {
      var $editor = $("#" + ed.id),
          $editorIframe = $("#" + ed.id + "_ifr").contents(),
          dialogStr = 'div.' + sketchSetting.appName + '.' + sketchSetting.sketchType,
          writingCanvasStr = dialogStr + " " + "canvas." + sketchSetting.sketchType,
          $writingCanvas;

          sketchSetting.stageId = ed.id + "_" + sketchSetting.sketchType;      // set stageId dynamic

          function init(){
              sketchSetting.saveImage = saveImg;
              HandWrite = new Sketcher(sketchSetting);

              //****** add close button
              var $close = $("<div style='text-align: right;'><a href='#' class='btn btn-info ui-close'>关闭</a></div>")
                  .click(function(){
                      $( dialogStr ).dialog( "close" );
                  });
              $(dialogStr).prepend($close);
                // end

              //****** choose brush
              HandWrite.brushSize = {width:9,height:9,step:1};
              $(".big_brush").trigger("click");
                // end
          }

          //****** if first open box
          if(!$(dialogStr).size()) { init();}
          // end


          $writingCanvas = $(writingCanvasStr);
          $(dialogStr).dialog({
              width:"95%",
              minHeight:$(window).height(),
              dialogClass: sketchSetting.sketchType,
              "resizable": false,
              modal: true,
              close: function() {
                  HandWrite.reset();
              }
          });

          function saveImg(){
              var writeW = HandWrite.writingEdge.rightBottom.x - HandWrite.writingEdge.leftTop.x;
              var writeH = sketchSetting.canvasH;

              var cropLeft = HandWrite.writingEdge.leftTop.x - $writingCanvas.offset().left;

              var $copyCanvas = $("<canvas></canvas>").attr({
                  width: writeW/7,
                  height: writeH/7
              });

              var copyCanvasContext = $copyCanvas.get(0).getContext("2d");
              copyCanvasContext.drawImage($writingCanvas.get(0),
                  cropLeft,0,writeW,writeH,
                  0,0,writeW/7,writeH/7
              );

              var copyCanvasData = $copyCanvas.get(0).toDataURL();
              var $div = $("<div></div>"),
                  $img = $("<img/>").attr("src",copyCanvasData).addClass(sketchSetting.sketchType);

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

