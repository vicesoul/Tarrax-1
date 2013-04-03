/**
 * Copyright (C) 2011 Instructure, Inc.
 *
 * This file is part of Canvas.
 *
 * Canvas is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License as published by the Free
 * Software Foundation, version 3 of the License.
 *
 * Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

define([
  'i18n!quizzes.show',
  'jquery' /* $ */,
  'quiz_arrows',
  'quiz_inputs',
  'underscore',
  'jquery.instructure_date_and_time' /* dateString, time_field, datetime_field */,
  'jqueryui/dialog',
  'jquery.instructure_misc_helpers' /* scrollSidebar */,
  'jquery.instructure_misc_plugins' /* ifExists, confirmDelete */,
  'message_students', /* messageStudents */
  'vendor/raphael',
  'quizzes_tpl'
], function(I18n, $, showAnswerArrows, inputMethods, _) {

$(document).ready(function () {

  function loadStudents() {
    return $('.student_list .student').not('.blank').map(function() {
      return {
        id       : $(this).attr('data-id'),
        name     : $.trim($(this).find(".name").text()),
        submitted: $(this).closest(".student_list").hasClass('submitted')
      };
    });
  }

  showAnswerArrows();
  inputMethods.disableInputs('[type=radio], [type=checkbox]');
  inputMethods.setWidths();
  
  $(".delete_quiz_link").click(function(event) {
    event.preventDefault();
    students = loadStudents();
    submittedCount = $.grep(students, function(s) { return s.submitted; }).length
    var deleteConfirmMessage = I18n.t('confirms.delete_quiz', "Are you sure you want to delete this quiz?");
    if (submittedCount < 0) {
      deleteConfirmMessage += "\n\n" + I18n.t('confirms.delete_quiz_submissions_warning',
	      {'one': "Warning: 1 student has already taken this quiz. If you delete it, any completed submissions will be deleted and no longer appear in the gradebook.",
	       'other': "Warning: %{count} students have already taken this quiz. If you delete it, any completed submissions will be deleted and no longer appear in the gradebook."},
	      {'count': submittedCount});
    }
    $("nothing").confirmDelete({
      url: $(this).attr('href'),
      message: deleteConfirmMessage,
      success: function() {
        window.location.href = $('#context_quizzes_url').attr('href');
      }
    });
  });
  var hasOpenedQuizDetails = false;
  $(".quiz_details_link").click(function(event) {
    event.preventDefault();
    var $quizResultsText = $('#quiz_results_text');
    if (hasOpenedQuizDetails) {
      if (ENV.IS_SURVEY) {
        $quizResultsText.text(I18n.t('links.show_student_survey_results',
                                     'Show Student Survey Results'));
      } else {
        $quizResultsText.text(I18n.t('links.show_student_quiz_results',
                                     'Show Student Quiz Results'));
      }
    } else {
      if (ENV.IS_SURVEY) {
        $quizResultsText.text(I18n.t('links.hide_student_survey_results',
                                     'Hide Student Survey Results'));
      } else {
        $quizResultsText.text(I18n.t('links.hide_student_quiz_results',
                                     'Hide Student Quiz Results'));

      }
    }
    $("#quiz_details").slideToggle();
    hasOpenedQuizDetails = !hasOpenedQuizDetails;
  });
  $(".message_students_link").click(function(event) {
    event.preventDefault();
    students = loadStudents();
    var title = $("#quiz_title").text();

    window.messageStudents({
      options: [
        {text: I18n.t('have_taken_the_quiz', "Have taken the quiz")},
        {text: I18n.t('have_not_taken_the_quiz', "Have NOT taken the quiz")}
      ],
      title: title,
      students: students,
      callback: function(selected, cutoff, students) {
        students = $.grep(students, function($student, idx) {
          var student = $student.user_data;
          if(selected == I18n.t('have_taken_the_quiz', "Have taken the quiz")) {
            return student.submitted;
          } else if(selected == I18n.t('have_not_taken_the_quiz', "Have NOT taken the quiz")) {
            return !student.submitted;
          }
        });
        return $.map(students, function(student) { return student.user_data.id; });
      }
    });
  });
  $.scrollSidebar();
  
  $("#let_students_take_this_quiz_button").ifExists(function($link){
    var $unlock_for_how_long_dialog = $("#unlock_for_how_long_dialog");

    $link.click(function(){
      $unlock_for_how_long_dialog.dialog('open');
      return false;
    });

    var unlock_button = {
      text: I18n.t('buttons.unlock', 'Unlock'),
      click: function(){
        var dateString = $(this).find('.datetime_suggest').text();

        $link.closest('form')
          // append this back to the form since it got moved to be a child of body when we called .dialog('open')           
          .append($(this).dialog('destroy'))
          .find('#quiz_lock_at')
            .val(dateString).end()
          .submit();
      }
    };

    $unlock_for_how_long_dialog.dialog({
      autoOpen: false,
      modal: true,
      resizable: false,
      width: 400,
      buttons: [ unlock_button ]
      //buttons: {
        //'Unlock' : function(){
          //var dateString = $(this).find('.datetime_suggest').text();

          //$link.closest('form')
            //// append this back to the form since it got moved to be a child of body when we called .dialog('open')           
            //.append($(this).dialog('destroy'))
            //.find('#quiz_lock_at')
              //.val(dateString).end()
            //.submit();
        //}
      //}
    }).find('.datetime_field').datetime_field();
  });

  $('#lock_this_quiz_now_link').ifExists(function($link) {
    $link.click(function(e) {
      e.preventDefault();
      $link.closest('form').submit();
    })
  });

  if ($('ul.page-action-list').find('li').length > 0) {
    $('ul.page-action-list').show();
  }

  $('#publish_quiz_form').formSubmit({
    beforeSubmit: function(data) {
      $(this).find('button').attr('disabled', true).text(I18n.t('buttons.publishing', "Publishing..."));
    },
    success: function(data) {
      $(this).find('button').text(I18n.t('buttons.published', "Published!"));
      location.reload();
    }
  });
  
  (function connectingLead(){
    $(".question.connecting_lead_question").each(function(){

      var $question = $(this),
        linesNum = $question.find(".connecting_lead_linesNum").text(),
        $answers_wrapper = $question.find(".answers_wrapper"),
        rows = $answers_wrapper.find(".connecting_lead_left").length,
        $answers = $question.find(".answers"),
        $correctAnswer = $(this).find(".answers_wrapper_correct"),
        answerHeight = 40 * rows,
        paper = Raphael( $answers_wrapper[0], $answers_wrapper.width(), answerHeight );

      $answers_wrapper.css( "height", answerHeight );
      
      if( linesNum == 3 ) $question.addClass("threeLines");
      
      var devider = linesNum === "3" ? 3 : 2;
      $answers_wrapper.add($correctAnswer).each(function(){
        $(this).find(".connecting_lead_answer > div").each( function( i ){
          
          $(this).css({
            position: "absolute",
            left: ( $answers.width()/devider ) * (i%3),
            top: 40 * Math.floor(i/3)
          });
          console.log( ( $answers.width()/devider ) * (i%3) )

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
          if( linesNum === "2" && $(this).is(".right") )return;
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

        color = color === undefined ? "#08c" : color;
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
        $factory = $("<div class='factory'><div class='main'><div class='bg'></div></div></div>"),
        $main = $factory.find(".main");

      // reload image
      var bgImage = $("<img>").attr("src", imageSrc);
      $main.find(".bg").append(bgImage);

      // reload balls
      $.each(positionData, function(i,val){
        var text = val.text ? val.text : "";
        var $ball = $(tpl.ball);
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

      var paper = Raphael( $main[0], $answers.width(), 500 );

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

        color = color === undefined ? "#08c" : color;
        var lineType = dash ? "- " : "";
        line
          .attr({
            "stroke": color,
            "stroke-width": Global.quizzes.lineWidth,
            "stroke-dasharray": lineType
          });

      }

      function stringToObject(str) {
        return eval("(" + str + ")");
      }

    });
  })();

  (function DragAndDop(){
    $(".question.drag_and_drop_question").each(function(){
      var $blueText = $(this).find(".blueText");
      var $select = $blueText.find(".ui-selectmenu");
      var $receive = $("<div class='receive'></div>");

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

});

});
