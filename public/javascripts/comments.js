define([
    'INST' /* INST */,
    'i18n!gradebook',
    'jquery' /* $ */,
    'str/htmlEscape',
    'jqueryui/dialog',
    'jqueryui/slider',
    'jquery.instructure_misc_helpers',
    "kinetic-v4.0.1",
    "modernizr.custom.34982",
    "sketcher",
    "jquery.ui.touch"
], function(INST, I18n, $) {
    $(document).ready(function(){
        var $question  = $("#questions"),
            offset = $question.offset(),
            qWidth = $question.width(),
            qHeight = $question.height(),
            sketcher,
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

        var InitHTML = "<div class='comment_menu'>";
            InitHTML += "<input type='button' class='start_drawing' value='Draw'>";
            InitHTML += "<input type='button' class='high_light' value='Highlight'>";
            InitHTML += "</div>";
            $(InitHTML).appendTo($question);

        var drawingState = false;
        var $drawingApp;
        $(".start_drawing").click(function(){
            // ****** if first open box
            if($(".drawing_app").length == 0) {
                defaultSetting.stageId = "comment_drawing_container";      // set stageId dynamic
                defaultSetting.canvasW = qWidth;
                defaultSetting.canvasH = qHeight;
                sketcher = new Sketcher(defaultSetting);
                $drawingApp = $(".drawing_app");
                $drawingApp.appendTo($question);



            }
            // ****** end
            else{

                $drawingApp.removeClass("ghost");
            }

        });

        $(".high_light").click(function(){
            $drawingApp.addClass("ghost");

        });


        function initCanvas(){

            $("<canvas></canvas>").attr({
                width:qWidth,
                height:qHeight
            })
                .addClass("sketch")
                .appendTo($question);

            if(drawingState){
                $(document).unbind("mousedown");
                drawingState = false;
            }else{
                $(document).bind("mousedown",downHandle());
                drawingState = true;
            }
        }
        function downHandle(){
            return function(e){
                line = paper.path();
                line.attr("stroke", "#ff6600");
                pathArray = ["M",e.pageX-offset.left,e.pageY-offset.top];
                $(this).bind("mousemove",moveHandle())

            }
        }

        function moveHandle(){
            return function(e){
                //console.log(line.attr("path"));
                pathArray.push(e.pageX-offset.left,e.pageY-offset.top);
                line.attr("path",pathArray);

            }
        }

        $(document).mouseup(function(){
            $(this).unbind("mousemove");
        })


    })




});