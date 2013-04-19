define([
    'compiled/editor/stocktiny',
    'i18n!editor',
    'jquery',
    'str/htmlEscape',
    'jqueryui/slider',
    'jquery.instructure_misc_helpers',
    "modernizr.custom.34982",
    'Backbone',
    "sketcher"
], function(tinymce, I18n, $) {

    var HandWrite,
        $mask,
        pluginProp = {id:"instructureHandWrite",name:"instructure_handWrite"},
        sketchSetting = {  
            sketchType:"handWrite",
            id:"",
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

          if( HandWrite == undefined ) {
              sketchSetting.id = ed.id;
              initial();
          }
              HandWrite.set("id",ed.id);

          //$("#ipadScale").attr("content","user-scalable=no");
          HandWrite.App.dialog({
            width: sketchSetting.canvasW + 70,
            minHeight: sketchSetting.canvasH,
            title:sketchSetting.appTitle,
            dialogClass: sketchSetting.sketchType,
            "resizable": false,
            close: function() {
              HandWrite.reset();
            }
          });

          function initial(){
              var Write = Sketcher.extend({

                  onCanvasMouseDown : function () {
                      var self = this;

                      return function(event) {
                          if( event.button == 2 )return false;        // forbidden right mouse
                          self.writeState = true;
                          console.log("down")
                          clearTimeout(self.timeOut_mouseUp);
                          self.lines.push([]);

                          self.mouseMoveHandler = self.onCanvasMouseMove();
                          self.mouseUpHandler = self.onCanvasMouseUp();

                          // unbind the event if in ie, when drawing out the canvas to select the text out of canvas, than back in canvas drawing the line always drawing
                          if ( $.browser.msie ){self.canvas.unbind( self.mouseMoveEvent);}




                          self.canvas.bind( self.mouseMoveEvent, self.mouseMoveHandler );
                          $(document).bind(self.mouseUpEvent,self.mouseUpHandler);

                          self.updateMousePosition( event );
                          //self.renderFunction( event );           // click drawing
                          return false;      //**** ie & chrome bug, stop the mouse selecting the outer text
                      }
                  },

                  onCanvasMouseUp : function (event) {
                      var self = this;
                      return function(event) {

                          if( !self.writeState ) return;
                          console.log("up")
                          self.timeOut_mouseUp = setTimeout(function(){

                              if( !self.writeState ) return;

                                  self.saveImg();
                                  self.reset();

                          },700);

                          /*console.log( self.canvas.data("events") );
                          self.canvas.unbind( self.mouseMoveEvent, self.mouseMoveHandler );
                          $(document).unbind(self.mouseUpEvent,self.mouseUpHandler);*/

                          self.canvas.unbind( self.mouseMoveEvent );
                          $(document).unbind(self.mouseUpEvent );

                      }
                  },

                  reset : function () {
                      this.writeState = false;
                      clearTimeout(this.timeOut_mouseUp);
                      this.lines = [];
                      this.clear();
                      this.writingEdge = {leftTop:{x:9999,y:9999},rightBottom:{x:0,y:0}};
                  },

                  saveImg : function () {
                      var self = this;
                      //****** rewrite character and get the new data
                      var writeW = this.writingEdge.rightBottom.x - this.writingEdge.leftTop.x;
                      var writeH = this.get("canvasH");
                      var cropLeft = this.writingEdge.leftTop.x - this.canvas.offset().left;
                      var $copyCanvas = $("<canvas></canvas>").attr({
                          width: writeW/7 + 1,
                          height: writeH/7 + 1
                      });
                      var copyCanvasContext = $copyCanvas.get(0).getContext("2d");
                      copyCanvasContext.strokeStyle = "#000000";
                      copyCanvasContext.lineWidth = 1.2;
                      $.each(self.lines, function(i){
                          $.each(self.lines[i], function(k,value){
                              if( k == 0 ){
                                  copyCanvasContext.beginPath();

                                  copyCanvasContext.moveTo( ( value[0]-cropLeft )/7, ( value[1] ) /7 );
                              }else{
                                  copyCanvasContext.lineTo( ( value[0] - cropLeft )/7, ( value[1] )/7 );
                                  if( k == ( self.lines[i].length - 1 ) ){
                                      copyCanvasContext.stroke();
                                  }
                              }
                          });
                      });
                      var copyCanvasData = $copyCanvas.get(0).toDataURL();
                      // end

                      //****** insert image
                      var $div = $("<div></div>"),
                          $img = $("<img/>").attr("src",copyCanvasData).addClass(this.get("sketchType"));
                      $div.append($img);
                      var $editor = $("#" + this.get("id"));
                      $editor.editorBox('insert_code', $div.html());
                      // end

                  }

              });

              HandWrite = new Write(sketchSetting);

              //****** add  buttonSet

              //var $scale = $('<meta id="ipadScale" name="viewport" content="user-scalable=no" />').prependTo("head");
              var buttonSet = $("<div class='buttons-set'></div>");

              var $undo = $("<span class='btn-undo'>撤销</span>")
                  .bind("mousedown",function(){
                      tinymce.activeEditor.undoManager.undo();
                  }).appendTo(buttonSet);
                  
              var $redo = $("<span class='btn-redo'>redo</span>")
                  .bind("mousedown",function(){
                      tinymce.activeEditor.undoManager.redo();
                  }).appendTo(buttonSet);

              /*var $return = $("<span href='#' class='btn btn-success'><i class='ico-white ico-arrow-left'></i>换行</span>")
                  .click(function(){
                      var $editor = $("#" + ed.id);
                      //tinyMCE.activeEditor.selection.select(tinyMCE.activeEditor.dom.select('p')[0]);
                     $editor.editorBox('insert_code', "<br/>");
                  }).appendTo(buttonSet);*/

              /*var $close = $("<a href='#' class='btn-close'>关闭</a>")
                  .click(function(e){
                      e.preventDefault();
                      HandWrite.App.hide();
                      $mask.hide();
                      $("#ipadScale").attr("content","user-scalable=yes");
                  }).appendTo(buttonSet);*/

              HandWrite.App.prepend(buttonSet);
              // end

              /*tinymce.activeEditor.dom.addClass(tinymce.activeEditor.dom.select('p'), 'someclass');
              ed.onUndo.add(function(ed, level) { console.log('Undo was performed: ' + level.content); });*/
              
              

              //****** choose brush
              HandWrite.brushSize = {width:9,height:9,step:1};
              $(".big_brush").trigger("click");
              // end

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

