
define([
  'jquery',
  'underscore'
], function($, _) {
var tpl  = window.tpl = {};
tpl.ball = '<span><div class="popover"><div class="arrow"></div><div class="popover-content"><p></p></div></div></span>';

var Global = window.Global = {};
Global.quizzes = {
  connectingOnPic:  function ($form){

    // generate HTML
    var $factory = $form.find(".factory");
    var $formAnswers = $form.find(".form_answers");
    var $main = $factory.find(".main");
    var textWidth = parseFloat( $(".text").width() );
    
    if($main.find("svg").size() === 1){$main.find("svg").remove()}
    
    var defaultWidth = 680;
    var defaultHeight = 500;
    var factoryWidth = parseFloat( $factory.width() );
    var mainHeight = ( defaultHeight / defaultWidth ) * factoryWidth;
    var paper = Raphael( $main[0], textWidth, mainHeight );
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
        $ball.css({
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

        $ball.find("textarea").click(function(e){
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
      var $ball = $factory.find(".menu span").filter("." + color).clone();
      $ball.find("textarea").html(text).end()
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

      $ball.find("textarea").click(function(e){
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
      var strokeColor = "#08c",
        x1 = $active.position().left + $active.width()/2,
        y1 = $active.position().top + $active.height()/2 ,
        x2 = $end.position().left + $end.width()/2,
        y2 = $end.position().top + $end.height()/2 ,
        line = paper.path("M" + x1 + " " + y1 + "L" + x2 + " " + y2);
      line
        .attr({
          "stroke": strokeColor,
          "stroke-width": Global.quizzes.lineWidth
        })
        .click(function(e){
          e.stopPropagation();
          resetToolTip($toolTip, paper);
          this.attr({"stroke-dasharray": "- "});
          $toolTip
            .show()
            .css({
              left: e.pageX,
              top: e.pageY
            });
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
        var value = $(this).val();
        if( "ball-" + greyBallId == value || value == "" ){
          isNewBall = false;
          if( value == "" ){
            $(this).val("ball-" + greyBallId);
          }
          $(this).closest(".connecting_on_pic_answer").find(".answer_match_right input").doVal("add",yellowBallId);
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
        .css("max-width", "100px")
        .attr("data-content", text)
        .popover({
          placement: orientation,
          trigger: "hover"
        });
    }
  },

  lineWidth: 3
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
    var strokeColor = "#08c",
      x1 = $active.position().left + $active.width()/2,
      y1 = $active.position().top + $active.height()/2 ,
      x2 = $end.position().left + $end.width()/2,
      y2 = $end.position().top + $end.height()/2 ,
      line = paper.path("M" + x1 + " " + y1 + "L" + x2 + " " + y2);
    line
      .attr({
        "stroke": strokeColor,
        "stroke-width": Global.quizzes.lineWidth
      })
      .click(function(e){
        e.stopPropagation();
        resetToolTip($toolTip, paper);
        this.attr({"stroke-dasharray": "- "});
        $toolTip
          .show()
          .css({
            left: e.pageX,
            top: e.pageY
          });
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
      el.attr("stroke-dasharray", "");
    });
  }
};

_.extend(window, Global.quizzes.commonFunc);


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