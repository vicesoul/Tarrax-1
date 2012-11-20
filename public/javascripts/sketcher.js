function Sketcher(setting) {

    this.defaultSetting = setting;
    this.brushImg = new Image();
	this.renderFunction = this.updateCanvasByLine;
	this.touchSupported = Modernizr.touch;


	this.lastMousePoint = {x:0, y:0};
    this.brushSize = {width:15,height:15,step:.3};

	if (this.touchSupported) {

		this.mouseDownEvent = "touchstart";
		this.mouseMoveEvent = "touchmove";
		this.mouseUpEvent = "touchend";
	}
	else {


		this.mouseDownEvent = "mousedown";
		this.mouseMoveEvent = "mousemove";
		this.mouseUpEvent = "mouseup";
	}



    this.initial();
}

Sketcher.prototype.initial = function(){
    this.generalHTML();
    this.canvas = $(".container canvas." + this.defaultSetting.canvasClass);
    this.context = this.canvas.get(0).getContext("2d");
    this.context.strokeStyle = "#" + this.defaultSetting.color.hex;
    this.context.lineWidth = this.defaultSetting.lineW;
    this.canvas.bind( this.mouseDownEvent, this.onCanvasMouseDown() );

}

Sketcher.prototype.generalHTML = function(){

    var self = this,
        stage,
        layer,
    canvasHtml  = '<div class="drawing_app">';
    canvasHtml += '<input type="button" value="清空" class="clear_all" />';
    canvasHtml += '<input type="button" value="圆珠笔" class="line" />';
    canvasHtml += '<input type="button" value="墨水" class="ink" />';
    canvasHtml += '<input type="button" value="刷子" class="big_brush" />';
    canvasHtml += '<input type="button" value="橡皮擦" class="eraser" />';
    canvasHtml += '<div class="color_setting">';
    canvasHtml += '<input type="button" class="black" value="black" style="background:#000000;" data-color=' + '{hex:"000000",rgb:[0,0,0]} ' + '  />';
    canvasHtml += '<input type="button" class="blue" value="blue" style="background:#0000ff;" data-color=' + '{hex:"0000ff",rgb:[0,0,255]} ' + '  />';
    canvasHtml += '<input type="button" class="red" value="red" style="background:#ff0000;" data-color=' + '{hex:"ff0000",rgb:[250,0,0]} ' + '  />';
    canvasHtml += '<input type="button" class="green" value="green" style="background:#7cfc00;" data-color=' + '{hex:"7cfc00",rgb:[124,252,0]} ' + '  />';
    canvasHtml += '<input type="button" class="orange" value="orange" style="background:#FF7940;" data-color=' + '{hex:"FF7940",rgb:[255,121,64]} ' + '  />';
    canvasHtml += '<input type="button" class="purple" value="purple" style="background:#9932cc;" data-color=' + '{hex:"9932cc",rgb:[153,50,204]} ' + '  />';
    canvasHtml += '<input type="button" class="brown" value="pink" style="background:#ff69b4;" data-color=' + '{hex:"ff69b4",rgb:[255,105,180]} ' + '  />';
    canvasHtml += '</div>';
    canvasHtml += '<div class="setLineSize"><label>Line</label><div></div><input type="text"></div>';
    canvasHtml += '<div class="setBrushSize"><label>Brush</label><div></div><input type="text"></div>';
    canvasHtml += ' <div class="container"><div class="img_background"></div><div id="' + self.defaultSetting.stageId +'"></div></div>';
    canvasHtml += '<div class="containerDraft"><canvas class="canvasDraft" width="39" height="39"></canvas></div>';
    canvasHtml += '</div>';

    $("body").append( canvasHtml );

    stage = new Kinetic.Stage({
        container: self.defaultSetting.stageId,
        width: this.defaultSetting.canvasW,
        height: this.defaultSetting.canvasH
    });

    layer = new Kinetic.Layer({
        visible:false,
        id:"uuoo"
    });

    stage.add(layer);

    $("#" + self.defaultSetting.stageId + " canvas").addClass(self.defaultSetting.canvasClass);

    $(".color_setting input:gt(1)").hide();

    $(".clear_all").click(function(){
        self.clear();
    });

    $(".line").click(function(){
        self.defaultSetting.tools.type = "line";
        $(".color_setting").find("input").show().end().find("input:gt(1)").hide();
        $(".color_setting input[type=button]:first").trigger("click");
    });

    $(".ink").click(function(){
        self.defaultSetting.tools = {type:"brush",src:"/javascripts/tinymce/jscripts/tiny_mce/plugins/instructure_drawing/canvas/assets/ink_s.png"};
        $(".color_setting").find("input").show().end().find("input:gt(1)").hide();
        $(".color_setting input[type=button]:first").trigger("click");
    });

    $(".big_brush").click(function(){
        self.defaultSetting.tools = {type:"brush",src:"/javascripts/tinymce/jscripts/tiny_mce/plugins/instructure_drawing/canvas/assets/brush.png"};
        $(".color_setting input").show();
        $(".color_setting input[type=button]:first").trigger("click");
    });

    $(".eraser").click(function(){
        self.defaultSetting.tools.type = "eraser";
        $(".color_setting input").hide();
        self.setTools();
    });

    $(".color_setting input[type=button]").click(function(){
        var string = $(this).attr("data-color");
        eval('self.defaultSetting.color = '+string);
        self.setTools();
    });


    $("#setLineSize div").slider({
        max:5,
        min:1,
        value: this.defaultSetting.lineW,
        create: function(event, ui) {
            $(this).next("input").val(self.defaultSetting.lineW);
        },
        slide: function(event, ui) {
            $(this).next("input").val(ui.value);
        } ,
        change: function(event, ui) {
            self.context.lineWidth = ui.value;
            $(this).next("input").val(ui.value);
        }
    }).addTouch();

    $("#setBrushSize div").slider({
        max:39,
        min:19,
        value: 39,
        create: function(event, ui) {
            $(this).next("input").val("39");
        },
        slide: function(event, ui) {
            $(this).next("input").val(ui.value);
        },
        change: function(event, ui) {
            self.brushSize.width = ui.value;
            self.brushSize.height = ui.value;
            $(this).next("input").val(ui.value);
        }
    }).addTouch();

}

Sketcher.prototype.setTools = function(){
    var self = this;
    if(self.defaultSetting.tools.type == "line"){
        this.context.strokeStyle = "#" + self.defaultSetting.color.hex;
        this.renderFunction = this.updateCanvasByLine;
    }else if(self.defaultSetting.tools.type == "brush"){
        var canvas = $(".canvasDraft").get(0);
        var context = canvas.getContext("2d");

        context.clearRect(0,0,39,39);

        var draftBrush = new Image();
        draftBrush.src = self.defaultSetting.tools.src;
        draftBrush.onload = function() {
            context.drawImage(draftBrush,0,0,39,39);

            var imageData = context.getImageData(0, 0, 39, 39);
            imgData = imageData.data;

            for(var i = 0; i < imgData.length; i += 4) {
                imgData[i] = self.defaultSetting.color.rgb[0];
                imgData[i + 1] = self.defaultSetting.color.rgb[1];
                imgData[i + 2] = self.defaultSetting.color.rgb[2];
            }
            context.putImageData(imageData, 0, 0);

            dataURL = canvas.toDataURL();

            var newBrush = new Image();
            newBrush.src = dataURL;
            newBrush.onload = function(){
                self.brushImg = newBrush;
                self.renderFunction = self.updateCanvasByBrush;

            };
        };
    }else if(self.defaultSetting.tools.type == "eraser"){
        self.renderFunction = self.updateCanvasByEraser;
    }
}

Sketcher.prototype.onCanvasMouseDown = function () {
	var self = this;

	return function(event) {
		self.mouseMoveHandler = self.onCanvasMouseMove()
		self.mouseUpHandler = self.onCanvasMouseUp()

        self.canvas.bind( self.mouseMoveEvent, self.mouseMoveHandler );
        self.canvas.bind( self.mouseUpEvent, self.mouseUpHandler );

		self.updateMousePosition( event );
		//self.renderFunction( event );           // click drawing
        event.stopPropagation($(this));
	}
}

Sketcher.prototype.onCanvasMouseMove = function () {
	var self = this;
	return function(event) {

		self.renderFunction( event );
     	event.preventDefault();
        event.stopPropagation($(this));
    	return false;
	}
}

Sketcher.prototype.onCanvasMouseUp = function (event) {
	var self = this;
	return function(event) {
        self.canvas.unbind( self.mouseMoveEvent, self.mouseMoveHandler );
        self.canvas.unbind( self.mouseUpEvent, self.mouseUpHandler );
        event.stopPropagation($(this));
	}
}

Sketcher.prototype.updateMousePosition = function (event) {
 	var target;
	if (this.touchSupported) {
		target = event.originalEvent.touches[0]
	}
	else {
		target = event;
	}

	var offset = this.canvas.offset();
	this.lastMousePoint.x = target.pageX - offset.left;
	this.lastMousePoint.y = target.pageY - offset.top;

}

Sketcher.prototype.updateCanvasByLine = function (event) {
    this.defaultSetting.tools.type = "line";
	this.context.beginPath();

	this.context.moveTo( this.lastMousePoint.x, this.lastMousePoint.y );

	this.updateMousePosition( event );
	this.context.lineTo( this.lastMousePoint.x, this.lastMousePoint.y );
	this.context.stroke();
}

Sketcher.prototype.updateCanvasByBrush = function (event) {
	//var halfBrushW = this.brush.width/2;
	//var halfBrushH = this.brush.height/2;
    var self = this;
	var start = { x:this.lastMousePoint.x, y: this.lastMousePoint.y };
	this.updateMousePosition( event );
	var end = { x:this.lastMousePoint.x, y: this.lastMousePoint.y };
	
	var distance = parseInt( this.distanceBetween2Points( start, end ) );

	var angle = this.angleBetween2Points( start, end );
	
	var x,y;

	for ( var z=0; (z<distance ); z= z + self.brushSize.step )
	{
		x = start.x + (Math.sin(angle) * z) - self.brushSize.width/2;
		y = start.y + (Math.cos(angle) * z) - self.brushSize.height/2;
        		//console.log( x, y, angle, z );


                self.context.drawImage(self.brushImg, x, y,self.brushSize.width,self.brushSize.height);


	}
}

Sketcher.prototype.updateCanvasByEraser = function (event) {
    //var halfBrushW = this.brush.width/2;
    //var halfBrushH = this.brush.height/2;

    var start = { x:this.lastMousePoint.x, y: this.lastMousePoint.y };
    this.updateMousePosition( event );
    var end = { x:this.lastMousePoint.x, y: this.lastMousePoint.y };

    var distance = parseInt( this.distanceBetween2Points( start, end ) );

    var angle = this.angleBetween2Points( start, end );

    var x,y;
    var r = 10;

    for ( var z=0; (z<distance ); z= z+this.brushSize.step )
    {
        x = start.x + (Math.sin(angle) * z) ;
        y = start.y + (Math.cos(angle) * z) ;
        this.context.clearRect( x-r,y-r ,2*r, 2*r );
    }
}

Sketcher.prototype.distanceBetween2Points = function ( point1, point2 ) {

    var dx = point2.x - point1.x;
    var dy = point2.y - point1.y;
    return Math.sqrt( Math.pow( dx, 2 ) + Math.pow( dy, 2 ) );
}

Sketcher.prototype.angleBetween2Points = function ( point1, point2 ) {

    var dx = point2.x - point1.x;
    var dy = point2.y - point1.y;
    return Math.atan2( dx, dy );
}

Sketcher.prototype.toString = function () {

	var dataString = this.canvas.get(0).toDataURL("image/png");
	var index = dataString.indexOf( "," )+1;
	dataString = dataString.substring( index );
	
	return dataString;
}

Sketcher.prototype.toDataURL = function () {

	var dataString = this.canvas.get(0).toDataURL("image/png");
	return dataString;
}

Sketcher.prototype.clear = function () {

	var c = this.canvas[0];
	this.context.clearRect( 0, 0, c.width, c.height );
}
			