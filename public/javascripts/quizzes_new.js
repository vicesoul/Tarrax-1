
define([
  'jquery',
  'underscore',
  'i18n!account_homepage'
], function($, _, I18n) {
var tpl  = window.tpl = {};
tpl.factory = {};
tpl.factory.structure = "<div class='factory'><div class='main'><div class='bg'></div><div class='lines'></div></div></div>";
tpl.factory.menu = "<div class='menu'><ul><li><span class='grey'><b>╳</b></span></li><li><span class='yellow'><b>╳</b></span></li></ul></div>";
tpl.factory.ball = '<span><div class="popover"><div class="arrow"></div><div class="popover-content"><p></p></div></div></span>';
tpl.factory.popover = "<div class='popover'><div class='arrow'></div><div class='popover-content'><textarea></textarea></div></div>";

var Global = window.Global = {};
Global.quizzes = {
  lineWidth: 5,
  strokeColor: "#08c",
  strokeChosenColor: "grey",

  dragLine : {

    state : false,

    start : function(){
      this.attr({"stroke": Global.quizzes.strokeChosenColor});
    },

    move : function(){
      Global.quizzes.dragLine.state = true
    },

    up : function(deleFunc, $active, $end, $toolTip, $question){
      return function(){
        if(Global.quizzes.dragLine.state == true){
          deleFunc(this, $active, $end, $toolTip, $question)();
          Global.quizzes.dragLine.state = false;
        }
      }
      
    }

  },

  connectingOnPic:  function ($form){

    // fixes svg bug
    if($form.find(".factory").size() === 1){
      $form.find(".factory").remove();
    }

    // generate HTML
    var $imageInput = $form.find("input.connecting_on_pic_image");
    var $factory = $(tpl.factory.structure);
    var $formAnswers = $form.find(".form_answers");
    var $main = $factory.find(".main");
    var $lines = $factory.find(".lines");
    var textWidth = parseFloat( $(".text").width() );
    var $menu = $(tpl.factory.menu);
    $main.before($menu);
    $imageInput.after($factory);
    
    var defaultWidth = 680;
    var defaultHeight = 500;
    var factoryWidth = parseFloat( $factory.width() );
    var mainHeight = ( defaultHeight / defaultWidth ) * factoryWidth;
    var paper = Raphael( $lines[0], textWidth, mainHeight );
    $main.css({
      height: mainHeight
    });

    var deleHandle,
      positionStr = $formAnswers.closest(".question_holder").find(".connecting_on_pic_position").text(),
      positionData = positionStr == "" ? {} : stringToObject( positionStr ),
      imageSrc = $formAnswers.closest(".question_holder").find(".connecting_on_pic_image").text(),
      ballId = 0,
      $toolTip = $("#toolTip").bind("click", function(e){ e.stopPropagation(); });


    $toolTip.find("button:last").bind("click", function(){ resetToolTip($toolTip, paper); });

    // show uploaded images
    if( $("#editor_tabs_4").is(":hidden") ){$("#ui-id-5").trigger("click");}

    // semi radical
    var spanWidth = $factory.find(".menu span:first").css("width");
    var r = parseFloat(spanWidth)/2;

    // init balls
    $factory.find(".menu span").draggable({
      helper: "clone",
      zIndex: 100,
      cursorAt: { left: r, top: r }
    });

    // init images
    $(".image_list").mouseover(function(){
      $(this).find("img").draggable({
        helper: "clone"
      });
    });

    // init image container
    $main.find(".bg")
      .droppable({
        accept: ".image_list img",
        activeClass: "ui-state-highlight",
        drop: function( event, ui ) {
          console.log(ui);
          var imgSrc = ui.helper.attr("data-url") || ui.helper.attr("src");
          var $img = $("<img>").attr("src",imgSrc);
          $img.appendTo( $(this).empty())
            .mousedown(function(){
              return false;
            });

          $formAnswers.closest(".question_holder").find(".connecting_on_pic_image").val( imgSrc );
        }
      });

    // init balls container
    $main.droppable({
      accept: $factory.find(".menu span"),
      activeClass: "ui-state-highlight",
      drop: function( event, ui ) {
        var $ball = ui.draggable.clone();
        var orientation = $ball.is(".grey") ? "left" : "right";
        var $popover = $(tpl.factory.popover).addClass(orientation);
        $ball
          .append($popover)
          .css({
            position: "absolute",
            left: event.pageX - $(this).offset().left - r,
            top: event.pageY - $(this).offset().top - r
          })
          .draggable({
            containment: "parent",
            stop: function( event, ui ) {
              updatePosition();
            },
            drag: function( event, ui ) {
              updateLines();
            }
          })
          .attr("ball-id", ballId)
          .appendTo( $(this) )
          .bind( "click", ballHandle )
          .find("b")
          .bind( "click", deleBall );

        $ball.find("textarea")
          .bind("click mousedown", function(e){
            e.stopPropagation();
          })
          .blur(function(){
            saveText( this );
          });

        ballId ++;
        updatePosition();

      }
    });

    // reload balls
    $.each(positionData, function(i,val){
      var text = val.text ? val.text : "";
      var color = val.Grey ? "grey" : "yellow";
      var orientation = val.Grey ? "left" : "right";
      var $popover = $(tpl.factory.popover).addClass(orientation);
      var $ball = $factory.find(".menu span").filter("." + color).clone();

      $ball
        .append($popover)
        .find("textarea").html(text).end()
        .css({
          position: "absolute",
          left: val.x,
          top: val.y
        })
        .draggable({
          containment: "parent",
          stop: function( event, ui ) {
            updatePosition();
          },
          drag: function( event, ui ) {
            updateLines();
          }
        })
        .attr("ball-id", i)
        .appendTo( $main )
        .bind( "click", ballHandle )
        .find("b")
        .bind( "click", deleBall );

      $ball.find("textarea")
        .bind("click mousedown", function(e){
          e.stopPropagation();
        })
        .blur(function(){
          saveText( this );
        });

      ballId = parseInt(ballId) > parseInt(i) ? ballId : i;

    });
    ballId ++;

    // reload lines
    updateLines();

    // reload image
    var bgImage = $("<img>").attr("src", imageSrc);
    $main.find(".bg").append(bgImage);

    // close tooltip when click document
    $(document).click(function(){ resetToolTip($toolTip, paper) });



    function updateLines(){
      paper.clear();

      $formAnswers.find(".connecting_on_pic_answer .answer_match_left input").each(function(){
        var greyBallId = $(this).val().slice(5);
        // fix ie8 bug
        if($(this).val() == $(this).attr("placeholder")){
          return;
        }

        var $grey = $main.find("> span[ball-id="+ greyBallId + "]");
        var rightInput = $(this).closest(".connecting_on_pic_answer").find(".answer_match_right input");
        var rightVal = rightInput.val();
        if(rightVal == "")return;
        var yellowBalls = rightVal.split("ball-");
        $.each(yellowBalls, function(i,val){
          if(val == "")return;
          var $yellow = $main.find("> span[ball-id="+ val + "]");
          drawLine( $grey, $yellow );
        });

      });

    }

    function ballHandle(){
      var $active = $main.find( ".active"),
        $greyBall = $active.is(".grey") ? $active : $(this),
        $yellowBall = $active.is(".grey") ? $(this) : $active,
        connected = false;

      // check if they are connected
      $formAnswers.find(".answer .connecting_on_pic_answer").each(function( i ){
        var leftVal = $(this).find("input[name=connecting_on_pic_left]").val(),
          rightVal = $(this).find("input[name=connecting_on_pic_right]").val(),
          greyBallId = $greyBall.attr("ball-id"),
          yellowBallId = $yellowBall.attr("ball-id");
        if( leftVal.slice(5) == greyBallId && rightVal.indexOf("ball-" + yellowBallId) != -1 ) {
          connected = true;
          return false;
        }
      });

      // toggle class: active
      if( $(this).is(".grey") && $active.is(".grey") && !$(this).is(".active")
        || $(this).is(".yellow") && $active.is(".yellow") && !$(this).is(".active")
        || connected
        ){
        $active.removeClass("active");
        $(this).addClass("active");
        return;
      }


      if( $main.find(".active").size() !== 0 ){
        if( !$(this).is(".active") ) {
          drawLine($greyBall, $yellowBall);
          addAnswer($greyBall, $yellowBall);
          $active.removeClass( "active" );
        }else{
          $(this).removeClass( "active" )
        }
      }else{
        // $active is not found
        $(this).addClass("active");
      }

    }

    function deleBall(){
      var $ball = $(this).parent("span");
      var ballId = $ball.attr("ball-id");
      var isGrey = $ball.is(".grey");
      deleText($ball.find("textarea"));
      $ball.remove();
      delete positionData[ballId];

      updatePosition();

      // dele answers
      $formAnswers.find(".connecting_on_pic_answer .answer_match_left input").each(function(){
        if(isGrey){
          if( $(this).val() == "ball-" + ballId ){
            $(this).closest(".answer").find(".delete_answer_link").trigger("click");
          }
        } else{
          $(this).closest(".connecting_on_pic_answer").find(".answer_match_right input").doVal("sub", ballId)
        }

      });
      updateLines();
    }

    function drawLine($active, $end ){
      var x1 = $active.position().left + $active.width()/2,
        y1 = $active.position().top + $active.height()/2 ,
        x2 = $end.position().left + $end.width()/2,
        y2 = $end.position().top + $end.height()/2 ,
        offx1 = $active.offset().left + $active.width()/2,
        offy1 = $active.offset().top + $active.height()/2 ,
        offx2 = $end.offset().left + $end.width()/2,
        offy2 = $end.offset().top + $end.height()/2 ,
        line = paper.path("M" + x1 + " " + y1 + "L" + x2 + " " + y2);



      var dragLine = Global.quizzes.dragLine;
      line
        .attr({
          "stroke": Global.quizzes.strokeColor,
          "stroke-width": Global.quizzes.lineWidth
        })
        .drag( dragLine.move, dragLine.start, dragLine.up(deleLine, $active, $end) )
        .click(function(e){
          e.stopPropagation();
          resetToolTip($toolTip, paper);
          this.attr({"stroke": Global.quizzes.strokeChosenColor});
          $toolTip
            .css({
              left: e.pageX || (offx1 + offx2)/2,
              top: e.pageY || (offy2 + offy2)/2
            })
            .show();

          deleHandle =  deleLine(this, $active, $end);
          $toolTip.find("button:first").bind( "click", deleHandle );
        });

    }

    function deleLine(line, a, b){
      return function(){
        $toolTip.hide();
        line.remove();

        // delete match answer
        var $grey = a.is(".grey") ? a : b;
        var $yellow = a.is(".grey") ? b : a;
        var greyBallId = $grey.attr("ball-id");
        var yellowBallId = $yellow.attr("ball-id");
        $formAnswers.find(".answer_match_left input").each(function(){
          var inputVal = $(this).val();
          if("ball-" + greyBallId == inputVal){
            $(this).closest(".connecting_on_pic_answer").find(".answer_match_right input").doVal("sub",yellowBallId);
            return false;
          }

        });
      }
    }

    function addAnswer($greyBall, $yellowBall){
      var greyBallId = $greyBall.attr("ball-id");
      var yellowBallId = $yellowBall.attr("ball-id");
      var isNewBall = true;
      $formAnswers.find(".connecting_on_pic_answer .answer_match_left input").each(function(){
        var leftValue = $(this).val();
        var leftPlaceholderAttr = $(this).attr("placeholder");
        var $rightInput = $(this).closest(".connecting_on_pic_answer").find(".answer_match_right input");

        if( "ball-" + greyBallId == leftValue || leftValue == "" || leftValue == leftPlaceholderAttr){

          isNewBall = false;
          
          // ie8 bug
          if( leftValue == "" || leftValue == leftPlaceholderAttr ){
            $(this).val("ball-" + greyBallId);
            $rightInput.val("");
          }

          // ie8 bug
          var rightValue = $rightInput.val();
          var rightPlaceholderAttr = $rightInput.attr("placeholder");
          if( rightValue == rightPlaceholderAttr ){
            $rightInput.val("");
          }

          $rightInput.doVal("add",yellowBallId);
          return false;

        }
      });

      if( isNewBall ){
        $formAnswers.closest(".question_holder").find(".add_answer_link").trigger("click");
        $formAnswers.find(".answer input[name=connecting_on_pic_left]:last").val("ball-" + greyBallId );
        $formAnswers.find(".answer input[name=connecting_on_pic_right]:last").val("ball-" + yellowBallId );
      }

    }

    function updatePosition(){
      $main.find("span.ui-draggable").each(function(){
        var ballId = $(this).attr("ball-id");
        var ballX =  Math.round( parseInt( $(this).css("left") ) / factoryWidth * 10000) / 100.00 + "%";
        var ballY =  Math.round( parseInt( $(this).css("top") ) / 500 * 10000 ) / 100.00 + "%";
        var isGrey = $(this).is(".grey");
        positionData[ballId] = positionData[ballId] === undefined ? {} : positionData[ballId];
        positionData[ballId]["x"] = ballX;
        positionData[ballId]["y"] = ballY;
        positionData[ballId]["Grey"] = isGrey;
      });
      positionData = JSON.stringify(positionData);
      $formAnswers.closest(".question_holder").find(".connecting_on_pic_position").val( positionData );
      positionData = stringToObject(positionData);
    }

    function saveText( textarea ){
      var ballId = $(textarea).closest("span.ui-draggable").attr("ball-id");
      positionData[ballId]["text"] = $(textarea).val();
      positionData = JSON.stringify(positionData);
      $formAnswers.closest(".question_holder").find(".connecting_on_pic_position").val( positionData );
      positionData = stringToObject(positionData);
    }

    function deleText( textarea ){
      var ballId = $(textarea).closest("span.ui-draggable").attr("ball-id");
      positionData[ballId]["text"] = $(textarea).val();
      positionData = JSON.stringify(positionData);
      $formAnswers.closest(".question_holder").find(".connecting_on_pic_position").val( positionData );
      positionData = stringToObject(positionData);
    }

  },

  connectingLead: function($form){
    var $display_question = $form.prev(".display_question");
    var isThreeLines = $form.closest(".question_holder").find(".connecting_lead_linesNum").text().trim() === "3";
    var $question = $form.find(">div.question");
    if(isThreeLines){
      $question.addClass("threeLines");
    }
  },

  popHover: function($container, idx){
    var $target = $container.find("span");
    var orientation = idx%3 === 0 ? "left" : "right";
    var text = $target.text().trim();
    if( text.length > 14 ){
      $target
        .addClass("ellipsis")
        .attr("data-content", text)
        .popover({
          placement: orientation,
          trigger: "hover"
        });

        $target.add($container).css("max-width", "100px");

    }
  },

  quizzesShow: function(){
    (function connectingLead(){
      $(".question.connecting_lead_question").each(function(){
        var $question = $(this),
          linesNum = $question.find(".connecting_lead_linesNum").text().trim(),
          $answers_wrapper = $question.find(".answers_wrapper"),
          rows = $answers_wrapper.find(".connecting_lead_left").length,
          $answers = $question.find(".answers"),
          $correctAnswer = $(this).find(".answers_wrapper_correct"),
          answerHeight = 40 * rows,
          paper = Raphael( $answers_wrapper[0], $answers_wrapper.width(), answerHeight );

        $answers_wrapper.css( "height", answerHeight );
        
        var isThreeLines = linesNum === "3";
        if( isThreeLines ) $question.addClass("threeLines");
        
        var devider = isThreeLines ? 3 : 2;
        $answers_wrapper.add($correctAnswer).each(function(){
          $(this).find(".connecting_lead_answer > div").each( function( i ){
            
            $(this).css({
              position: "absolute",
              left: ( $answers.width()/devider ) * (i%3),
              top: 40 * Math.floor(i/3)
            });


            Global.quizzes.popHover($(this), i);

          });
        });


        $answers_wrapper.find(".connecting_lead_center").each(function(){
          var $wordCenter = $(this);

          $(this).find(".question_input").each(function(){
            var matchId = $(this).val(),
             real_answer_Str = $(this).is(".left") ? ".real_answer.left" : ".real_answer.right",
             correctMatchId = $(this).parent().find( real_answer_Str ).val(),
             $match = $answers_wrapper.find("span[value='" + matchId +"']").parent(),
             colorStr = matchId === correctMatchId ? "green" : "red";
            if(matchId === "0" )return;
            drawLine(paper, $wordCenter, $match, colorStr );
          });

        });

        // ********   correct answer
        
        $correctAnswer.css( "height", answerHeight );
        $correctAnswer.find("svg").remove();
        var newPaper = Raphael( $correctAnswer[0], $answers.width(), answerHeight );
        $correctAnswer.find(".connecting_lead_center").each(function(){
          var $wordCenter = $(this);
          $(this).find(".real_answer").each(function(){
            if( !isThreeLines && $(this).is(".right") )return;
            var matchId = $(this).val();
            if(matchId === "0")return;
            var $match = $correctAnswer.find("span[value='" + matchId +"']").parent();
            drawLine(newPaper, $wordCenter, $match, "green" );
          });
        });
        $answers.css("opacity", 1);
        function drawLine(svg, $active, $end, color ){
          var normalPosition = $end.position().left > $active.position().left,
            $nodeB = normalPosition ? $end : $active,
            $nodeA = !normalPosition ? $end : $active,
            x2 = $nodeB.position().left - 10,
            y2 = $nodeB.position().top + $nodeB.height()/2,
            x1 = $nodeA.position().left + $nodeA.width() + 10,
            y1 = $nodeA.position().top + $nodeA.height()/2,
            line = svg.path("M" + x1 + " " + y1 + "L" + x2 + " " + y2);

          color = color === undefined ? Global.quizzes.strokeColor : color;
          line
            .attr({
              "stroke": color,
              "stroke-width": Global.quizzes.lineWidth
            });
        }

      });
    })();

    (function connectingOnPic(){
      $(".question.connecting_on_pic_question").each(function(){
        var $question = $(this),
          imageSrc = $question.find(".connecting_on_pic_image").text(),
          positionData = stringToObject( $question.find(".connecting_on_pic_position").text() ),
          $answers_wrapper = $question.find(".answers_wrapper"),
          $answers = $question.find(".answers"),
          $factory = $(tpl.factory.structure),
          $main = $factory.find(".main"),
          $lines = $factory.find(".main .lines");

        // reload image
        var bgImage = $("<img>").attr("src", imageSrc);
        $main.find(".bg").append(bgImage);

        // reload balls
        $.each(positionData, function(i,val){
          var text = val.text ? val.text : "";
          var $ball = $(tpl.factory.ball);
          var color = val.Grey ? "grey" : "yellow";
          var oritation = val.Grey ? "left" : "right";
          $ball.addClass(color)
            .find(".popover").addClass(oritation)
            .find(".popover-content p").html(text).end().end()
            .css({
              position: "absolute",
              left: val.x,
              top: val.y
            })
            .attr("ball-id", i)
            .appendTo( $main );
        });

        $factory.prependTo($answers_wrapper);

        var defaultWidth = 680;
        var defaultHeight = 500;
        var factoryWidth = parseFloat( $factory.width() );
        var mainHeight = ( defaultHeight / defaultWidth ) * factoryWidth;
        var paper = Raphael( $lines[0], $answers.width(), mainHeight );
        $main.css({
          height: mainHeight
        });

        updateUserAnswerLines();

        function updateUserAnswerLines(){
          $question.find(".answers .answers_wrapper .connecting_on_pic_left").each(function(){
            var greyBallId = $(this).find("span").text().trim().slice(5);
            var $grey = $main.find("> span[ball-id="+ greyBallId + "]");
            var rightInput = $(this).next(".connecting_on_pic_right").find("input.left");
            var rightVal = rightInput.val();
            if(rightVal == "" || rightVal == "0")return;
            var yellowBalls = rightVal.split("ball-");

            var rightSpan = $(this).next(".connecting_on_pic_right").find("span");
            var rightText = rightSpan.text().trim();
            var answerYellowBalls = rightText.split("ball-");

            var missingYellowBalls = _.difference(answerYellowBalls, yellowBalls);
            $.each(missingYellowBalls, function(i,val){
              if(val == "")return;
              var $yellow = $main.find("> span[ball-id="+ val + "]");
              drawLine( $grey, $yellow, paper, "blue", true );
            });

            $.each(yellowBalls, function(i,val){
              if(val == "")return;
              var hasLine = $.inArray(val, answerYellowBalls) !== -1;
              var color = hasLine ? "green" : "red";
              var $yellow = $main.find("> span[ball-id="+ val + "]");
              drawLine( $grey, $yellow, paper, color );
            });
          });

        }

        function drawLine($active, $end, which, color, dash ){
          var x1 = $active.position().left + $active.width()/2,
            y1 = $active.position().top + $active.height()/2 ,
            x2 = $end.position().left + $end.width()/2,
            y2 = $end.position().top + $end.height()/2 ,
            line = which.path("M" + x1 + " " + y1 + "L" + x2 + " " + y2);

          color = color === undefined ? Global.quizzes.strokeColor : color;
          var lineType = dash ? "- " : "";
          line
            .attr({
              "stroke": color,
              "stroke-width": Global.quizzes.lineWidth,
              "stroke-dasharray": lineType
            });

        }

      });
    })();

    (function DragAndDop(){
      $(".question.drag_and_drop_question").each(function(){
        var $blueText = $(this).find(".blueText");
        var $select = $blueText.find(".ui-selectmenu");
        var $receive = $("<div class='receive'></div>");
        //fix bug
        var $firstLi = $(this).find(".dragging li:first");
        if($firstLi.text().trim() === "") $firstLi.remove();
        //
        $select.each(function(){
          $(this).hide()
            .parent("span")
            .after($receive.clone());
        });

      });

    }());

    (function FillInMultipleBlanksSubjective(){

      $(".question.fill_in_blanks_subjective_question").each(function(){
        var $question = $(this);
        $question.find(".question_text textarea").focus(function(){
          //$(this).blur();
        });

        $question.find(".answer-list li").each(function(i){
          var answer = $(this).html();
          var $textArea = $question.find(".question_text textarea").eq(i);
          var $div = $("<div class='blank'></div>");
          $div.html(answer);
          $textArea.after($div);
          $textArea.hide();
        });

      });

    }());

    (function multipleSelect() {
      $(".question_holder .multiple_dropdowns_question").each(function(){
        $(this).find(".text .question_text select").selectmenu('disable');
        var answers = []
        $(this).find(".answers .answer_group").each(function(i){
          if($(this).find(".selected_answer.correct_answer").size() !== 0){
            answers[i] = true
          }
        })

        $(this).find(".text a.ui-selectmenu").each(function(i){
          var style;
          if(answers[i] == true){
            style = "3px solid green"
          } else{
            style = "3px solid red"
          }
          $(this).css({
            "border": style
          })
        })

      })
    }())

  }

  
};



Global.quizzes.commonFunc = {

  stringToObject : function (str) { 
    return eval("(" + str + ")");
  },

  ballHandle : function ($question, paper, $toolTip){
    return function(){
      var $main = $question.find(".factory .main");
        $active = $main.find( ".active"),
        $greyBall = $active.is(".grey") ? $active : $(this),
        $yellowBall = $active.is(".grey") ? $(this) : $active,
        greyBallId = $greyBall.attr("ball-id"),
        yellowBallId = $yellowBall.attr("ball-id"),
        connected = false;

      // check if they are connected
      $question.find(".answers .word_left").each(function( i ){
        var answerId = $(this).find("span").text().trim().slice(5),
          answerVal = $(this).next(".word_right").find("input.left").val();
        if( answerId == greyBallId && answerVal.indexOf("ball-" + yellowBallId) != -1 ) {
          connected = true;
          return false;
        }
      });

      // toggle class: active
      if( $(this).is(".grey") && $active.is(".grey") && !$(this).is(".active")
        || $(this).is(".yellow") && $active.is(".yellow") && !$(this).is(".active")
        || connected
        ){
        $active.removeClass("active");
        $(this).addClass("active");
        return;
      }

      if( $main.find(".active").size() !== 0 ){
        if( !$(this).is(".active") ) {
          drawLine($greyBall, $yellowBall, $toolTip, paper, $question);
          addAnswer($greyBall, $yellowBall, $question);
          $active.removeClass( "active" );
        }else{
          $(this).removeClass( "active" )
        }
      }else{
        // $active is not found
        $(this).addClass("active");
      }
    }
  },

  updateLines : function ($question, paper, $toolTip){
    paper.clear();

    $question.find(".answers .word_left").each(function(){
      var greyBallId = $(this).find("span").text().trim().slice(5);
      var $grey = $question.find(".factory .main > span[ball-id="+ greyBallId + "]");
      var rightInput = $(this).next(".word_right").find("input.left");
      var rightVal = rightInput.val();
      if(rightVal == "" || rightVal == "0")return;
      var yellowBalls = rightVal.split("ball-");
      $.each(yellowBalls, function(i,val){
        if(val == "")return;
        var $yellow = $question.find(".factory .main > span[ball-id="+ val + "]");
        drawLine( $grey, $yellow, $toolTip, paper, $question);
      });
    });

  },

  drawLine : function ($active, $end, $toolTip, paper, $question){
    var x1 = $active.position().left + $active.width()/2,
      y1 = $active.position().top + $active.height()/2 ,
      x2 = $end.position().left + $end.width()/2,
      y2 = $end.position().top + $end.height()/2 ,
      offx1 = $active.offset().left + $active.width()/2,
      offy1 = $active.offset().top + $active.height()/2 ,
      offx2 = $end.offset().left + $end.width()/2,
      offy2 = $end.offset().top + $end.height()/2 ,
      line = paper.path("M" + x1 + " " + y1 + "L" + x2 + " " + y2);

    var dragLine = Global.quizzes.dragLine;
    line
      .attr({
        "stroke": Global.quizzes.strokeColor,
        "stroke-width": Global.quizzes.lineWidth
      })
      .drag( dragLine.move, dragLine.start, dragLine.up(deleLine, $active, $end, $toolTip, $question) )
      .click(function(e){
        e.stopPropagation();

        resetToolTip($toolTip, paper);
        this.attr({"stroke": Global.quizzes.strokeChosenColor});

        $toolTip
          .css({
            left: e.pageX || (offx1 + offx2)/2,
            top: e.pageY || (offy2 + offy2)/2
          })
          .show();

        $toolTip.find("button:first").bind( "click", deleLine(this, $active, $end, $toolTip, $question) );
        
      });

  },

  addAnswer : function ($greyBall, $yellowBall, $question){
    var greyBallId = $greyBall.attr("ball-id");
    var yellowBallId = $yellowBall.attr("ball-id");
    $question.find(".answers .word_left").each(function(){
      var answerId = $(this).find("span").text().trim().slice(5);
      if(greyBallId ==  answerId){
        $(this).next(".word_right").find("input.left").doVal("add", yellowBallId);
        return false;
      }
    });
  },

  deleLine : function (line, a, b, $toolTip, $question){
    return function(){
      $toolTip.hide();
      line.remove();

      // delete match answer
      var $grey = a.is(".grey") ? a : b;
      var $yellow = a.is(".grey") ? b : a;
      var greyBallId = $grey.attr("ball-id");
      var yellowBallId = $yellow.attr("ball-id");
      $question.find(".answers .word_left").each(function(){
        var answerId = $(this).find("span").text().trim().slice(5);
        if(greyBallId ==  answerId){
          $(this).next(".word_right").find("input.left").doVal("sub", yellowBallId);
          return false;
        }

      });
    }
  },

  resetToolTip : function ($toolTip, paper){
    $toolTip.hide();
    $toolTip.find("button:first").unbind("click");
    paper.forEach(function (el) {
      el.attr("stroke", Global.quizzes.strokeColor);
    });
  }
};



Global.uploadImage = {
  afterUploadedImageSuccess : function() {
    var content = I18n.t('#accounts.homepage.dialog.tip.uploaded_success', "Image has bean uploaded");
    dialogMessage(content);

  },

  validateUploadedImage : function(imageVal) {
    var content, flag;
    flag = true;
    content = I18n.t('#accounts.homepage.dialog.error.empty_image', 'Please confirm your image is not empty');
    if (imageVal === '') {
      flag = false;
    } else if (!(/\.(?:png|jpg|jpeg|bmp|gif)$/i.test(imageVal))) {
      content = I18n.t('#accounts.homepage.dialog.error.incorrect_image_type', 'Please confirm your image type is correct');
      flag = false;
    }
    if (!flag) {
      dialogMessage(content);
    }
    return flag;
  },

  dialogMessage : function(content){
    $('<div>' + content + '</div>').dialog({
      open: function( event, ui ) {
        $dialog = $(this);
        var closeDialog = function(){ 
          $dialog.remove() 
        };
        var t = setTimeout(closeDialog, 1500);
      }
    });
  }

};
_.extend(window, Global.quizzes.commonFunc);
_.extend(window, Global.uploadImage);

$.fn.doVal = function(type, yellowId) {
  var inputVal = $(this).val();
  inputVal = inputVal == false ? "" : inputVal;
  if(type == "add"){
    if(inputVal.indexOf("ball-" + yellowId) !== -1){
    }else{
      $(this).val( inputVal + "ball-" + yellowId ).trigger("change");
    }

  }else if( type == "sub" ){

    inputVal = inputVal.replace("ball-" + yellowId, "");
    $(this).val(inputVal).trigger("change");

  }
  return this;
};

$.fn.doNone = function() {
  return this;
};


});