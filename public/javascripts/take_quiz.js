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
  'i18n!quizzes.take_quiz',
  'jquery' /* $ */,
  'quiz_timing',
  'compiled/behaviors/autoBlurActiveInput',
  'compiled/tinymce',
  'jquery.ajaxJSON' /* ajaxJSON */,
  'jquery.instructure_date_and_time' /* friendlyDatetime, friendlyDate */,
  'jquery.instructure_forms' /* getFormData, errorBox */,
  'jqueryui/dialog',
  'jquery.instructure_misc_helpers' /* scrollSidebar */,
  'compiled/jquery.rails_flash_notifications',
  'tinymce.editor_box' /* editorBox */,
  'vendor/jquery.scrollTo' /* /\.scrollTo/ */,
  'compiled/behaviors/quiz_selectmenu',
  'sketcher',
  'Backbone',
  'vendor/raphael',
  'i18n!editor',
  'quizzes_new',
  'bootstrap'
], function(I18n, $, timing, autoBlurActiveInput) {

  var lastAnswerSelected = null;
  var quizSubmission = (function() {
    var timeMod = 0,
        started_at =  $(".started_at"),
        end_at = $(".end_at"),
        startedAtText = started_at.text(),
        endAtText = end_at.text(),
        endAtParsed = endAtText && new Date(endAtText),
        $countdown_seconds = $(".countdown_seconds"),
        $time_running_time_remaining = $(".time_running,.time_remaining"),
        $last_saved = $('#last_saved_indicator');

    return {
      referenceDate: null,
      countDown: null,
      isDeadline: true,
      fiveMinuteDeadline: false,
      oneMinuteDeadline: false,
      submitting: false,
      dialogged: false,
      contentBoxCounter: 0,
      lastSubmissionUpdate: new Date(),
      currentlyBackingUp: false,
      started_at: started_at,
      end_at: end_at,
      time_limit: parseInt($(".time_limit").text(), 10) || null,
      oneAtATime: $("#submit_quiz_form").hasClass("one_question_at_a_time"),
      cantGoBack: $("#submit_quiz_form").hasClass("cant_go_back"),
      finalSubmitButtonClicked: false,
      updateSubmission: function(repeat, beforeLeave) {
        if(quizSubmission.submitting && !repeat) { return; }
        var now = new Date();
        if((now - quizSubmission.lastSubmissionUpdate) < 1000) { return }
        if(quizSubmission.currentlyBackingUp) { return; }
        quizSubmission.currentlyBackingUp = true;
        quizSubmission.lastSubmissionUpdate = new Date();
        var data = $("#submit_quiz_form").getFormData();

        $(".question_holder .question").each(function() {
          value = ($(this).hasClass("marked")) ? "1" : "";
          data[$(this).attr('id') + "_marked"] = value;
        });

        $last_saved.text(I18n.t('saving', 'Saving...'));
        var url = $(".backup_quiz_submission_url").attr('href');
        // If called before leaving the page (ie. onbeforeunload), we can't use any async or FF will kill the PUT request.
        if (beforeLeave){
          $.flashMessage(I18n.t('saving', 'Saving...'));
          $.ajax({
            url: url,
            data: data,
            type: 'PUT',
            dataType: 'json',
            async: false        // NOTE: Not asynchronous. Otherwise Firefox will cancel the request as navigating away from the page.
            // NOTE: No callbacks. Don't care about response. Just making effort to save the quiz
          });
        }
        else {
          $.ajaxJSON(url, 'PUT', data,
            // Success callback
            function(data) {
              $last_saved.text(I18n.t('saved_at', 'Quiz saved at %{t}', { t: $.friendlyDatetime(new Date()) }));
              quizSubmission.currentlyBackingUp = false;
              if(repeat) {
                setTimeout(function() {quizSubmission.updateSubmission(true) }, 30000);
              }
              if(data && data.end_at) {
                var endAtFromServer     = Date.parse(data.end_at),
                    submissionEndAt     = Date.parse(quizSubmission.end_at.text()),
                    serverEndAtTime     = endAtFromServer.getTime(),
                    submissionEndAtTime = submissionEndAt.getTime();

                quizSubmission.referenceDate = null;

                // if the new end_at from the server is different than our current end_at, then notify
                // the user that their time limit's changed and let updateTime do the rest.
                if (serverEndAtTime !== submissionEndAtTime) {
                  serverEndAtTime > submissionEndAtTime ?
                    $.flashMessage(I18n.t('notices.extra_time', 'You have been given extra time on this attempt')) :
                    $.flashMessage(I18n.t('notices.less_time', 'Your time for this quiz has been reduced.'));

                  quizSubmission.end_at.text(data.end_at);
                  endAtText   = data.end_at;
                  endAtParsed = new Date(data.end_at);
                }
              }
            },
            // Error callback
            function() {
            var current_user_id = $("#identity .user_id").text() || "none";
            quizSubmission.currentlyBackingUp = false;
            $.ajaxJSON(
                location.protocol + '//' + location.host + "/simple_response.json?user_id=" + current_user_id + "&rnd=" + Math.round(Math.random() * 9999999),
                'GET', {},
                function() {},
                function() {
                  $.flashError(I18n.t('errors.connection_lost', "Connection to %{host} was lost.  Please make sure you're connected to the Internet before continuing.", {'host': location.host}));
                }
            );

            if(repeat) {
              setTimeout(function() {quizSubmission.updateSubmission(true) }, 30000);
            }
          }, {timeout: 5000 });
        }
      },

      updateTime: function() {
        var now = new Date();
        var end_at = quizSubmission.time_limit ? endAtText : null;
        timeMod = (timeMod + 1) % 120;
        if(timeMod == 0 && !end_at && !quizSubmission.twelveHourDeadline) {
          quizSubmission.referenceDate = null;
          var end = endAtParsed;
          if(!quizSubmission.time_limit && (end - now) < 43200000) {
            end_at = endAtText;
          }
        }
        if(!quizSubmission.referenceDate) {
          $.extend(quizSubmission, timing.setReferenceDate(startedAtText, end_at, now));
        }
        if(quizSubmission.countDown) {
          var diff = quizSubmission.countDown.getTime() - now.getTime() - quizSubmission.clientServerDiff;
          if(diff <= 0) {
            diff = 0;
          }
          var d = new Date(diff);
          $countdown_seconds.text(d.getUTCSeconds());
          if(diff <= 0 && !quizSubmission.submitting) {
            quizSubmission.submitting = true;
            $("#submit_quiz_form").submit();
          }
        }
        var diff = quizSubmission.referenceDate.getTime() - now.getTime() - quizSubmission.clientServerDiff;
        if(quizSubmission.isDeadline) {
          if(diff < 1000) {
            diff = 0;
          }
          if(diff < 1000 && !quizSubmission.dialogged) {
            quizSubmission.dialogged = true;
            quizSubmission.countDown = new Date(now.getTime() + 10000);
            $("#times_up_dialog").show().dialog({
              title: I18n.t('titles.times_up', "Time's Up!"),
              width: "auto",
              height: "auto",
              modal: true,
              overlay: {
                backgroundColor: "#000",
                opacity: 0.7
              },
              close: function() {
                if(!quizSubmission.submitting) {
                  quizSubmission.submitting = true;
                  $("#submit_quiz_form").submit();
                }
              }
            });
          } else if(diff >    30000 && diff <    60000 && !quizSubmission.oneMinuteDeadline) {
            quizSubmission.oneMinuteDeadline = true;
            $.flashMessage(I18n.t('notices.one_minute_left', "One Minute Left"));
          } else if(diff >   250000 && diff <   300000 && !quizSubmission.fiveMinuteDeadline) {
            quizSubmission.fiveMinuteDeadline = true;
            $.flashMessage(I18n.t('notices.five_minutes_left', "Five Minutes Left"));
          } else if(diff >  1800000 && diff <  1770000 && !quizSubmission.thirtyMinuteDeadline) {
            quizSubmission.thirtyMinuteDeadline = true;
            $.flashMessage(I18n.t('notices.thirty_minutes_left', "Thirty Minutes Left"));
          } else if(diff > 43200000 && diff < 43170000 && !quizSubmission.twelveHourDeadline) {
            quizSubmission.twelveHourDeadline = true;
            $.flashMessage(I18n.t('notices.twelve_hours_left', "Twelve Hours Left"));
          }
        }
        quizSubmission.updateTimeString(diff);
      },
      updateTimeString: function(diff) {
        var date = new Date(Math.abs(diff));
        var yr = date.getUTCFullYear() - 1970;
        var mon = date.getUTCMonth();
        var day = date.getUTCDate() - 1;
        var hr = date.getUTCHours();
        var min = date.getUTCMinutes();
        var sec = date.getUTCSeconds();
        var times = [];
        if(yr) { times.push(I18n.t('years_count', "Year", {'count': yr})); }
        if(mon) { times.push(I18n.t('months_count', "Month", {'count': mon})); }
        if(day) { times.push(I18n.t('days_count', "Day", {'count': day})); }
        if(hr) { times.push(I18n.t('hours_count', "Hour", {'count': hr})); }
        if(true || min) { times.push(I18n.t('minutes_count', "Minute", {'count': min})); }
        if(true || sec) { times.push(I18n.t('seconds_count', "Second", {'count': sec})); }
        $time_running_time_remaining.text(times.join(", "));
      },
      updateFinalSubmitButtonState: function() {
        var allQuestionsAnswered = ($("#question_list li:not(.answered)").length == 0);
        var lastQuizPage = ($("#submit_quiz_form").hasClass('last_page'));
        var thisQuestionAnswered = ($("div.question.answered").length > 0);
        var oneAtATime = quizSubmission.oneAtATime;

        var active = (oneAtATime && lastQuizPage && thisQuestionAnswered) || allQuestionsAnswered;

        quizSubmission.toggleActiveButtonState("#submit_quiz_button", active);
      },
      updateNextButtonState: function(id) {
        var $question = $("#" + id);
        quizSubmission.toggleActiveButtonState('button.next-question', $question.hasClass('answered'));
      },
      toggleActiveButtonState: function(selector, primary) {
        var addClass = (primary ? 'btn-primary' : 'btn-secondary');
        var removeClass = (primary ? 'btn-secondary' : 'btn-primary');
        $(selector).addClass(addClass).removeClass(removeClass);
      }
    };
  })();

  $(document).mousedown(function(event) {
    lastAnswerSelected = $(event.target).parents(".answer")[0];
  }).keydown(function() {
    lastAnswerSelected = null;
  });

  $(function() {
    $.scrollSidebar();
    autoBlurActiveInput();

    if($("#preview_mode_link").length == 0) {
      window.onbeforeunload = function() {
        quizSubmission.updateSubmission(false, true);
        if(!quizSubmission.submitting && !quizSubmission.alreadyAcceptedNavigatingAway) {
          return I18n.t('confirms.unfinished_quiz', "You're about to leave the quiz unfinished.  Continue anyway?");
        }
      };
      $(document).delegate('a', 'click', function(event) {
        if($(this).closest('.ui-dialog,.mceToolbar,.ui-selectmenu').length > 0) { return; }
        
        if($(this).hasClass('no-warning')) {
          quizSubmission.alreadyAcceptedNavigatingAway = true
          return;
        }

        if(!event.isDefaultPrevented()) {
          var url = $(this).attr('href') || "";
          var hashStripped = location.href;
          if(hashStripped.indexOf('#')) {
            hashStripped = hashStripped.substring(0, hashStripped.indexOf('#'));
          }
          if(url.indexOf('#') == 0 || url.indexOf(hashStripped + "#") == 0) {
            return;
          }
          var result = confirm(I18n.t('confirms.navigate_away', "You're about to navigate away from this page.  Continue anyway?"));
          if(!result) {
            event.preventDefault();
          } else {
            quizSubmission.alreadyAcceptedNavigatingAway = true
          }
        }
      });
    }
    var $questions = $("#questions");
    $("#question_list")
      .delegate(".jump_to_question_link", 'click', function(event) {
        event.preventDefault();
        var $obj = $($(this).attr('href'));
        $("html,body").scrollTo($obj.parent());
        $obj.find(":input:first").focus().select();
      })
      .find(".list_question").bind({
        mouseenter: function(event) {
          var $this = $(this),
              data = $this.data(),
              title = I18n.t('titles.not_answered', "Haven't Answered yet");

          if ($this.hasClass('marked')) {
            title = I18n.t('titles.come_back_later', "You marked this question to come back to later");
          } else if ($this.hasClass('answered')) {
            title = I18n.t('titles.answered', "Answered");
          }
          $this.attr('title', title);

          if(!quizSubmission.oneAtATime) {
            data.relatedQuestion || (data.relatedQuestion = $("#" + $this.attr('id').substring(5)));
            data.relatedQuestion.addClass('related');
          }
        },
        mouseleave: function(event) {
          if(!quizSubmission.oneAtATime) {
            var relatedQuestion = $(this).data('relatedQuestion')
            relatedQuestion && relatedQuestion.removeClass('related');            
          }
        }
      });

    $questions.find('.group_top,.answer_select').bind({
      mouseenter: function(event) {
        $(this).addClass('hover');
      },
      mouseleave: function(event) {
        $(this).removeClass('hover');
      }
    });

    $questions
      .delegate(":checkbox,:radio,label", 'change mouseup', function(event) {
        var $answer = $(this).parents(".answer");
        if (lastAnswerSelected == $answer[0]) {
          $answer.find(":checkbox,:radio").blur();
          quizSubmission.updateSubmission();
        }
      })
      .delegate(":text,textarea,select", 'change', function(event, update) {
        var $this = $(this);
        if ($this.hasClass('numerical_question_input')) {
          var val = parseFloat($this.val());
          $this.val(isNaN(val) ? "" : val.toFixed(4));
        }
        if (update !== false) {
          quizSubmission.updateSubmission();
        }
      })
      .delegate(".numerical_question_input", {
        keyup: function(event) {
          var val = $(this).val();
          if (val === '' || !isNaN(parseFloat(val))) {
            $(this).triggerHandler('focus'); // makes the errorBox go away
          } else{
            $(this).errorBox(I18n.t('errors.only_numerical_values', "only numerical values are accepted"));
          }
        }
      })
      .delegate(".flag_question", 'click', function() {
        var $question = $(this).parents(".question");
        $question.toggleClass('marked');
        $("#list_" + $question.attr('id')).toggleClass('marked');
        quizSubmission.updateSubmission();
      })
      .delegate(".question_input", 'change', function(event, update, changedMap) {
        var $this = $(this),
            tagName = this.tagName.toUpperCase(),
            id = $this.parents(".question").attr('id'),
            val = "";
        if (tagName == "A") return;
        if (changedMap) { // reduce redundant jquery lookups and other calls
          if (changedMap[id]) return;
          changedMap[id] = true;
        }

        if (tagName == "TEXTAREA") {
          val = $this.editorBox('get_code');
        } else if ($this.attr('type') == "text" || "number") {        //*** 2012-12-07 rupert add "|| number"
          val = $this.val();
        } else if (tagName == "SELECT") {
          var $selects = $this.parents(".question").find("select.question_input");
          val = !$selects.filter(function() { return !$(this).val() }).length;
        } else {
          $this.parents(".question").find(".question_input").each(function() {
            if($(this).attr('checked') || $(this).attr('selected')) {
              val = true;
            }
          });
        }
        $("#list_" + id + ", #" + id)[val ? 'addClass' : 'removeClass']('answered');

        quizSubmission.updateFinalSubmitButtonState();
        quizSubmission.updateNextButtonState(id);
      })

    $questions.find(".question_input").trigger('change', [false, {}]);

    setInterval(function() {
      $("textarea.question_input").each(function() {
        $(this).triggerHandler('change', false);
      });
    }, 2500);

    $(".hide_time_link").click(function(event) {
      event.preventDefault();
      if($(".time_running").css('visibility') != 'hidden') {
        $(".time_running").css('visibility', 'hidden');
        $(this).text(I18n.t('show_time_link', "Show"));
      } else {
        $(".time_running").css('visibility', 'visible');
        $(this).text(I18n.t('hide_time_link', "Hide"));
      }
    });

    setTimeout(function() {
      $("#question_list .list_question").each(function() {
        var $this = $(this);
        if($this.find(".jump_to_question_link").text() == "Spacer") {
          $this.remove();
        }
      });
    }, 1000);

    // Suppress "<ENTER>" key from submitting a form when clicked inside a text input.
    $("#submit_quiz_form input[type=text]").keypress(function(e){
      if (e.keyCode == 13)
        return false;
    });

    $(".quiz_submit").click(function(event) {
      quizSubmission.finalSubmitButtonClicked = true;
    });

    $("#submit_quiz_form").submit(function(event) {
      $(".question_holder textarea.question_input").each(function() { $(this).change(); });

      var unanswered;
      var warningMessage;
      
      if(quizSubmission.cantGoBack) {
        if(!$(".question").hasClass("answered")) {
          warningMessage = I18n.t('confirms.cant_go_back_blank',
            "You can't come back to this question once you hit next. Are you sure you want to leave it blank?");
        }
      }

      if(quizSubmission.finalSubmitButtonClicked) {
        quizSubmission.finalSubmitButtonClicked = false; // reset in case user cancels

        if(quizSubmission.cantGoBack) {
          unseen = $("#question_list .list_question:not(.seen)").length;
          if(unseen > 0) {
            warningMessage = I18n.t('confirms.unseen_questions',
              {'one': "There is still 1 question you haven't seen yet.  Submit anyway?",
               'other': "There are still %{count} questions you haven't seen yet.  Submit anyway?"},
               {'count': unseen})            
          }
        }
        else {
          unanswered = $("#question_list .list_question:not(.answered)").length;
          if(unanswered > 0) {
            warningMessage = I18n.t('confirms.unanswered_questions',
              {'one': "You have 1 unanswered question (see the right sidebar for details).  Submit anyway?",
               'other': "You have %{count} unanswered questions (see the right sidebar for details).  Submit anyway?"},
               {'count': unanswered});            
          }
        }
      }

      if(warningMessage != undefined && !quizSubmission.submitting) {
        var result = confirm(warningMessage);
        if(!result) {
          event.preventDefault();
          event.stopPropagation();
          return false;
        }
      }        

      quizSubmission.submitting = true;
    });

    $(".submit_quiz_button").click(function(event) {
      event.preventDefault();
      $("#times_up_dialog").dialog('close');
    });

    setTimeout(function() {
      $(".question_holder textarea.question_input").each(function() {
        $(this).attr('id', 'question_input_' + quizSubmission.contentBoxCounter++);
        $(this).editorBox();
      });
    }, 2000);

    setInterval(quizSubmission.updateTime, 400);

    setTimeout(function() { quizSubmission.updateSubmission(true) }, 15000);

    // set the form action depending on the button clicked
    $("#submit_quiz_form button[type=submit]").click(function(event) {
      quizSubmission.updateSubmission();

      var action = $(this).data('action');
      if(action != undefined) {
        $('#submit_quiz_form').attr('action', action);          
      }
    });

    (function ipadInputType(){
      var isiPad = navigator.userAgent.match(/iPad/i) != null;
      if(!isiPad){return;}

      function isNumber(n) {
        return !isNaN(parseFloat(n)) && isFinite(n);
      }

      var $input = $("input[type=text]") || $("input[type=number]");

      var textType;

      $input.blur(function(){
        var lastText = $(this).val();
        if(!!lastText){
          if(isNumber(lastText)){
            textType = "number";
          }else{
            $(this).prop("type","text");
            textType = "text";
          }
        }
      });

      $input.focus(function(){
        var thisText = $(this).val();

        if(!!thisText){

          if(isNumber(thisText)){
            $(this).prop("type","number");
          }else{
            $(this).prop("type","text");
          }

        }else{
          if(textType == "number"){
            $(this).prop("type","number");
          }else{
            $(this).prop("type","text");
          }
        }
      });

      $input.keydown(function(e){
        var thisText = $(this).val();
        var keyDownIsText = (e.keyCode <= 90 && e.keyCode >= 65);

        if(!!thisText){

          if(isNumber(thisText)){
            if(keyDownIsText){
              $(this).prop("type","text");
            }else{
              $(this).prop("type","number");
            }
          }else{
            $(this).prop("type","text");
          }

        }else{
          if(keyDownIsText){
            $(this).prop("type","text");
          }else{
            $(this).prop("type","number");
          }
        }
      });

    })();

    (function paintQuestion(){
      
      if( $(".question.paint_question").size() === 0 ) return false;
      
      var sketchSetting = {
        sketchType:"paintQuestion",
        stageId:"",
        lineW : 1,
        canvasW : 740,
        canvasH : 400,
        color : {hex:"000000",rgb:[0,0,0]},
        tools : {type:"line",src:""},
        appName : "sketch_app",
        appTitle : "画板"
      };
          
      var Paint = Sketcher.extend({

        dealWithApp : function () {
          var self = this;
          var $text = $( "#" + self.get("stageId") ).find("div.text");
          $text.prepend( self.App );

          var $editor = self.canvas.closest(".paint_question").find(".question_input");
          var str = $editor.text();
          var $img = $(str).find("img");
          if( $img.size() !== 0 ){
            $img[0].onload = function() {
              self.context.drawImage(this, 0, 0);
            };

            
          }

        },

        onCanvasMouseUp : function (event) {
          var self = this;

          return function(event) {
            self.canvas.unbind( self.mouseMoveEvent, self.mouseMoveHandler );
            $(document).unbind(self.mouseUpEvent,self.mouseUpHandler);

            var data = self.canvas[0].toDataURL();
            var $img = $("<img>").attr( "src", data).addClass("paint-image");
            var $div = $("<div></div>").append($img);
            var $editor = self.canvas.closest(".paint_question").find(".question_input");
            $editor.editorBox( 'set_code', "" );
            $editor.editorBox( 'insert_code', $div.html() );

          }
        }


      });

      $("#submit_quiz_form .paint_question").each(function(){
        // sketchSetting.canvasW = $(this).find(".text").width();
        var $question = $(this);
        var $text = $question.find(".text");
        var $images = $text.find("img:last");

        // check all the images is loaded
        if( !!$images.size() ){
          if($images.prop('complete')){
            triggerApp($question)
          } else{
            $images[0].onload = function(){
              triggerApp($question)
            };
          }
        }else{
          triggerApp($question)
        }

        function triggerApp($question){
          sketchSetting.canvasH = $text.height() - 120;
          sketchSetting.stageId = $question.attr("id");
          var Painter = new Paint(sketchSetting);
          Painter.App.find(".tools .line").trigger("click");
        }

        
        

      });
      
    })();

    (function ConnectingLead(){

      $("#submit_quiz_form .question.connecting_lead_question").each(function(){

        var readyLine,             // the line that is active
          $question = $(this),
          linesNum = $question.find(".connecting_lead_linesNum").text(),
          rows = $question.find(".word_left").length,
          $answers = $question.find(".answers"),
          answerHeight = 40 * rows,
          $toolTip = $("#toolTip").bind("click", function(e){ e.stopPropagation(); }),
          paper = Raphael( $answers[0], $answers.width(), answerHeight );

        $toolTip.find("button:last").bind("click", function(){resetToolTip( $toolTip, paper);})

        if( linesNum === "2" ) $question.addClass("threeLines");
        $answers.css( "height", answerHeight );

        $(document).click(function(){ resetToolTip( $toolTip, paper ) });
        
        var devider = linesNum === "3" ? 3 : 2;
        $(this).find(".connecting_lead").each( function( i ){
          $(this).css({
            position: "absolute",
            left: ( $answers.width()/devider ) * (i%3),
            top: 40 * Math.floor(i/3)
          });

          $(this).bind( "click", function(){

            if(  $(this).is(".leftSelected.rightSelected")
              || $(this).is(".word_left") && $(this).add(".active").is(".leftSelected")
              || $(this).is(".word_right") && $(this).add(".active").is(".rightSelected")
              || $(this).is(".word_center.leftSelected") && $(".active").is(".word_left")
              || $(this).is(".word_center.rightSelected") && $(".active").is(".word_right")
              )
              return;

            var thisLine = i%3;
            if( readyLine === undefined ) {
              $(this).addClass("active");
              readyLine = thisLine;
            } else if( Math.abs( readyLine - thisLine ) !== 1 ) {
              $(this).is( ".active" ) ? readyLine = undefined : $(this).closest( ".answers" ).find( ".active").toggleClass( "active" );
              $(this).toggleClass( "active" );
            } else{
              var active = $question.find( ".active" );
              drawLine( active, $(this) );
              $(this).closest( ".answers" ).find( ".active").toggleClass( "active" );
              readyLine = undefined;
            }

          });

          Global.quizzes.popHover($(this), i);

        });

        // ****** when reload, redraw the lines
        $(this).find(".word_center").each(function(){
          var $wordCenter = $(this);
          $(this).find(".question_input").each(function(){
            var matchId = $(this).val();
            if( !matchId )return;
            var $match = $question.find("span[value='" + matchId +"']").parent();
            drawLine($wordCenter, $match );
          });
        });

        // show answer after drawing lines
        $answers.css("opacity", 1);

        $(this).bind( "mousedown", function(){
          return false;
        });

        function drawLine( $active, $end ){
          var checkName = $end.is(".word_left") || $active.is(".word_left") ? "leftSelected" : "rightSelected",
            $towNOde = $end.add( $active ).addClass( checkName ),
            normalPosition = $end.position().left > $active.position().left,
            $nodeB = normalPosition ? $end : $active,
            $nodeA = !normalPosition ? $end : $active,
            x2 = $nodeB.position().left - 10,
            y2 = $nodeB.position().top + $nodeB.height()/2 + 5,
            x1 = $nodeA.position().left + $nodeA.width() + 10,
            y1 = $nodeA.position().top + $nodeA.height()/2 + 5,
            line = paper.path("M" + x1 + " " + y1 + "L" + x2 + " " + y2);

          line
            .attr({
              "stroke": "#08c",
              "stroke-width": Global.quizzes.lineWidth
            })
            .click(function(e){
              e.stopPropagation();
              resetToolTip( $toolTip, paper );
              this.attr({"stroke-dasharray": "- "});
              $toolTip
                .show()
                .css({
                  left: e.pageX,
                  top: e.pageY
                });
              $toolTip.find("button:first").bind( "click", deleLine(this, $active, $end) );
            });

          var $A = $active.is( ".word_center" ) ? $active : $end;    // is center
          var $B = !$active.is( ".word_center" ) ? $active : $end;   // is sidebar
          var matchId = $B.find("span").attr("value");
          $B.is( ".word_left" ) ? $A.find(".left").val(matchId).trigger("change") : $A.find(".right").val(matchId).trigger("change");

        }

        function deleLine(line, $leadA, $leadB){
          return function(){
            var $nodeA = $leadA.is(".word_center") ? $leadB : $leadA;   // $nodeA is sidebar
            var $nodeB = !$leadA.is(".word_center") ? $leadB : $leadA;  // $nodeB is center
            // empty value
            $nodeA.is(".word_left") ? $nodeB.find(".left").val("").trigger("change") : $nodeB.find(".right").val("").trigger("change");

            // both is leftSelected or rightSelected,  coz both is already shared the same className
            var className = $leadA.is(".leftSelected") && $leadB.is(".leftSelected") ? "leftSelected" : "rightSelected";
            $leadA.add( $leadB ).removeClass( className );
            $toolTip.hide();
            line.remove();
          }
        }

      });

    })();

    (function ConnectingOnPic(){

      $("#submit_quiz_form .question.connecting_on_pic_question").each(function(){

        var $question = $(this),
          imageSrc = $question.find(".connecting_on_pic_image").text(),
          positionData = stringToObject( $question.find(".connecting_on_pic_position").text() ),
          $answers = $question.find(".answers"),
          $factory = $("<div class='factory'><div class='main'><div class='bg'></div></div></div>"),
          $main = $factory.find(".main"),
          $toolTip = $("#toolTip").bind("click", function(e){ e.stopPropagation(); }),
          paper = Raphael( $main[0], $answers.width(), 500 );

        $toolTip.find("button:last").bind("click", function(){resetToolTip($toolTip, paper); })
        $factory.prependTo($answers);
        //$answers.css( "height", 500 );

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
            .bind("click", function(e){ e.stopPropagation() })
            .find(".popover-content p").html(text)
            .end()[ !!text ? "doNone" : "hide"]()
            .end()
            .css({
              position: "absolute",
              left: val.x,
              top: val.y
            })
            .attr("ball-id", i)
            .appendTo( $main )
            .bind( "click", ballHandle($question, paper, $toolTip) );
        });

        updateLines($question, paper, $toolTip);

        $(document).click(function(){ resetToolTip($toolTip, paper) });


        // show answer after drawing lines
        $answers.css("opacity", 1);

        $(this).bind( "mousedown", function(){
          return false;
        });

      });


    })();

    (function DragAndDop(){
      $("#submit_quiz_form .question.drag_and_drop_question").each(function(){
        var $blueText = $(this).find(".blueText");
        var $select = $blueText.find(".ui-selectmenu");
        var $receive = $("<div class='receive'></div>");
        var $ball = $(this).find(".dragging li span");
        
        //fix bug
        var $firstLi = $(this).find(".dragging li:first");
        if($firstLi.text().trim() === "") $firstLi.remove();
        //

        $ball.draggable({
          revert: true
        });

        $select.each(function(){
          $(this).hide()
            .parent("span")
            .after($receive.clone());
        });

        $(this).find(".receive").each(function(){
          $(this).droppable({
            accept: $(".text .ui-draggable, .receive"),
            activeClass: "ui-state-highlight",
            drop: function( event, ui ) {
              if($(this).find("span").size() ==1)return false;
              var text = ui.draggable.text().trim();
              var $ball = ui.draggable;
              var answerId = ui.draggable.attr("answerId");
              var $select = $(this).prev().prev("select");
              var $span = ui.draggable.clone().removeAttr("style")
                .draggable({
                  stop: function( event, ui ) {
                    $(this).remove();
                    $select.find("option:gt(0)").remove();
                    $ball.show();
                  }
                });
              $(this).html($span);
              ui.draggable.hide();
              $select.find("option:gt(0)").remove().end().append("<option value=" + answerId + ">" + text + "</option>").val(answerId).trigger("change");
            }
          })
        });



      });
    }());

    (function FillInMultipleBlanksSubjective(){
      $("#submit_quiz_form .question.fill_in_blanks_subjective_question").each(function(){
        var $questionText = $(this).find(".question_text");
        var $textarea = $questionText.find("textarea.question_input");
        var $spanData = $(this).find(".answers >div >span[data-submission^='[']");
        if($spanData.attr("data-submission") != undefined){
          var textareaData = $spanData[0].dataset[ "submission" ];
          textareaData = stringToObject(textareaData);
          $textarea.each(function(i){
            $(this).html(textareaData[i]);
          });
        }

        // set tag p's css
        var t = setTimeout(function(){
          $questionText.find("iframe").contents().find("body").addClass("fill_in_blanks_subjective_question");
        }, 3000);

      });

    }());

    
    
  });


});


