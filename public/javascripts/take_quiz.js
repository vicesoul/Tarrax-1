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
  'vendor/raphael',
  'i18n!editor',
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
      updateSubmission: function(repeat, beforeLeave) {
        if(quizSubmission.submitting && !repeat) { return; }
        var now = new Date();
        if((now - quizSubmission.lastSubmissionUpdate) < 1000) { return }
        if(quizSubmission.currentlyBackingUp) { return; }
        quizSubmission.currentlyBackingUp = true;
        quizSubmission.lastSubmissionUpdate = new Date();
        var data = $("#submit_quiz_form").getFormData();
        $(".question_holder .question.marked").each(function() {
          data[$(this).attr('id') + "_marked"] = "1";
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
              $last_saved.text(I18n.t('saved_at', 'Saved at %{t}', { t: $.friendlyDatetime(new Date()) }));
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
            $.ajaxJSON(location.protocol + '//' + location.host + "/simple_response.json?user_id=" + current_user_id + "&rnd=" + Math.round(Math.random() * 9999999), 'GET', {}, function() {
            }, function() {
              ajaxErrorFlash(I18n.t('errors.connection_lost', "Connection to %{host} was lost.  Please make sure you're connected to the Internet before continuing.", {'host': location.host}), request);
            }, {skipDefaultError: true});

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
          data.relatedQuestion || (data.relatedQuestion = $("#" + $this.attr('id').substring(5)));
          data.relatedQuestion.addClass('related');
        },
        mouseleave: function(event) {
          var relatedQuestion = $(this).data('relatedQuestion')
          relatedQuestion && relatedQuestion.removeClass('related');
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
        $("#list_" + id)[val ? 'addClass' : 'removeClass']('answered');
      })
      .find(".question_input").trigger('change', [false, {}]);


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

    $("#submit_quiz_form").submit(function(event) {
      $(".question_holder .paint_question canvas.paintQuestion").each(function(){
        var data = $(this)[0].toDataURL();
        var $img = $("<img>").attr( "src", data).addClass("paint-image");
        var $div = $("<div></div>").append($img);
        var $editor = $(this).closest(".paint_question").find(".question_input");
        $editor.editorBox( 'set_code', "" );
        $editor.editorBox( 'insert_code', $div.html() );


      });
      $(".question_holder textarea.question_input").each(function() { $(this).change(); });
      unanswered = $("#question_list .list_question:not(.answered)").length;
      if(unanswered && !quizSubmission.submitting) {
        var result = confirm(I18n.t('confirms.unanswered_questions', {'one': "You have 1 unanswered question (see the right sidebar for details).  Submit anyway?", 'other': "You have %{count} unanswered questions (see the right sidebar for details).  Submit anyway?"}, {'count': unanswered}));
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

    var current_user_id = $("#identity .user_id").text() || "none";
    setInterval(function() {
      $.ajaxJSON(location.protocol + '//' + location.host + "/simple_response.json?user_id=" + current_user_id + "&rnd=" + Math.round(Math.random() * 9999999), 'GET', {}, function() {
      }, function() {
        ajaxErrorFlash(I18n.t('errors.connection_lost', "Connection to %{host} was lost.  Please make sure you're connected to the Internet before continuing.", {'host': location.host}), request);
      }, {skipDefaultError: true});
    }, 30000);

    setTimeout(function() { quizSubmission.updateSubmission(true) }, 15000);

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

    (function takePaintQuestion(){
      if( $(".question.paint_question").size() === 0 ) return false;
      var Painter,
          sketchSetting = {
            sketchType:"paintQuestion",
            stageId:"",
            lineW : 1,
            canvasW : 600,
            canvasH : 400,
            color : {hex:"000000",rgb:[0,0,0]},
            tools : {type:"line",src:""},
            appName : "sketch_app",
            appTitle : "画板"
          };
      $("#submit_quiz_form .paint_question").each(function(){
        sketchSetting.canvasW = $(this).find(".text").width();
        sketchSetting.canvasH = $(this).find(".text").height();
        sketchSetting.stageId = $(this).attr("id");
        Painter = new Sketcher(sketchSetting);
      });
    })();

    (function ConnectingLead(){

      $("#submit_quiz_form .question.connecting_lead_question").each(function(){

        var readyLine,             // the line that is active
          deleHandle,
          $question = $(this),
          linesNum = $question.find(".connecting_lead_linesNum").text(),
          rows = $question.find(".word_left").length,
          $answers = $question.find(".answers"),
          answerHeight = 40 * rows,
          $toolTip = $("<div><h5>" + I18n.t('line.dele_line', "Delete this line?") + "</h5></div>")
            .addClass("tool-tip")
            .hide()
            .bind("click", function(e){ e.stopPropagation(); })
            .appendTo( $answers ),
          $toolTipDele = $("<button type=button>确认</button>").appendTo($toolTip),
          $toolTipCancel = $( "<button type=button>取消</button>" )
            .bind("click", function(){resetToolTip();})
            .appendTo($toolTip),
          paper = Raphael( $answers[0], $answers.width(), answerHeight );

        if( linesNum == 2 ) $question.addClass("twoLines");
        $answers.css( "height", answerHeight );

        $(document).click(function(){ resetToolTip() });

        $(this).find(".connecting_lead").each( function( i ){

          $(this).css({
            position: "absolute",
            left: ( $answers.width()/3 ) * (i%3),
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

          /*if( $(this).find("span.btn").text().trim().length > 15 ){
            $(this).find("span.btn").popover({
              placement: "top",
              trigger: "hover"
            });
          }else{}*/

        });

        // ****** when reload, redraw the lines
        $(this).find(".word_center").each(function(){
          var $wordCenter = $(this);
          $(this).find(".question_input").each(function(){
            var matchId = $(this).val();
            if(matchId === "0")return;
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
              "stroke-width": 5
            })
            .click(function(e){
              e.stopPropagation();
              resetToolTip();
              this.attr({"stroke-dasharray": "- "});
              $toolTip
                .show()
                .css({
                  left: ( x1 + x2 )/2 - $toolTip.width()/2,
                  top: ( y1 + y2 )/2 - $toolTip.height() * 1.5
                });
              deleHandle =  deleLine(this, $active, $end);
              $toolTipDele.bind( "click", deleHandle );
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

        function resetToolTip(){
          $toolTip.hide();
          $toolTipDele.unbind( "click", deleHandle );
          paper.forEach(function (el) {
            el.attr("stroke-dasharray", "");
          });
        }

      });

    })();

    (function ConnectingOnPic(){

      $("#submit_quiz_form .question.connecting_on_pic_question").each(function(){

        var deleHandle,
          $question = $(this),
          imageSrc = $question.find(".connecting_on_pic_image").text(),
          positionData = stringToObject( $question.find(".connecting_on_pic_position").text() ),
          $answers = $question.find(".answers"),
          $factory = $("<div class='factory'><div class='main'><div class='bg'></div></div></div>"),
          $main = $factory.find(".main"),
          $toolTip = $("<div><h5>" + I18n.t('line.dele_line', "Delete this line?") + "</h5></div>")
            .addClass("tool-tip")
            .hide()
            .bind("click", function(e){ e.stopPropagation(); })
            .appendTo( $answers ),
          $toolTipDele = $("<button type=button>确认</button>").appendTo($toolTip),
          $toolTipCancel = $( "<button type=button>取消</button>" )
            .bind("click", function(){resetToolTip();})
            .appendTo($toolTip),
          paper = Raphael( $main[0], $answers.width(), 500 );

        $factory.prependTo($answers);
        //$answers.css( "height", 500 );

        // reload image
        var bgImage = $("<img>").attr("src", imageSrc);
        $main.find(".bg").append(bgImage);

        // reload balls
        $.each(positionData, function(i,val){
          var text = val.text ? val.text : "";
          var $ball = $("<span><p>" +
            text +
            "</p></span>");
          var color = val.Grey ? "grey" : "yellow";
          $ball.addClass(color)
            .css({
              position: "absolute",
              left: val.x,
              top: val.y
            })
            .attr("ball-id", i)
            .appendTo( $main )
            .bind( "click", ballHandle );



        });

        updateLines();

        $(document).click(function(){ resetToolTip() });


        // show answer after drawing lines
        $answers.css("opacity", 1);

        $(this).bind( "mousedown", function(){
          return false;
        });

        function ballHandle(){
          var $active = $main.find( ".active"),
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

        function updateLines(){
          paper.clear();

          $question.find(".answers .word_left").each(function(){
            var greyBallId = $(this).find("span").text().trim().slice(5);
            var $grey = $main.find("> span[ball-id="+ greyBallId + "]");
            var rightInput = $(this).next(".word_right").find("input.left");
            var rightVal = rightInput.val();
            if(rightVal == "" || rightVal == "0")return;
            var yellowBalls = rightVal.split("ball-");
            $.each(yellowBalls, function(i,val){
              if(val == "")return;
              var $yellow = $main.find("> span[ball-id="+ val + "]");
              drawLine( $grey, $yellow );
            });
          });

        }

        function drawLine($active, $end ){
          var strokeWidth = 5,
            strokeColor = "#08c",
            x1 = $active.position().left + $active.width()/2,
            y1 = $active.position().top + $active.height()/2 ,
            x2 = $end.position().left + $end.width()/2,
            y2 = $end.position().top + $end.height()/2 ,
            line = paper.path("M" + x1 + " " + y1 + "L" + x2 + " " + y2);
          line
            .attr({
              "stroke": strokeColor,
              "stroke-width": strokeWidth
            })
            .click(function(e){
              e.stopPropagation();
              resetToolTip();
              this.attr({"stroke-dasharray": "- "});
              $toolTip
                .show()
                .css({
                  left: ( x1 + x2 )/2 - $toolTip.width()/2,
                  top: ( y1 + y2 )/2 - $toolTip.height() * 1.5
                });
              deleHandle =  deleLine(this, $active, $end);
              $toolTipDele.bind( "click", deleHandle );
            });

        }

        function addAnswer($greyBall, $yellowBall){
          var greyBallId = $greyBall.attr("ball-id");
          var yellowBallId = $yellowBall.attr("ball-id");
          $question.find(".answers .word_left").each(function(){
            var answerId = $(this).find("span").text().trim().slice(5);
            if(greyBallId ==  answerId){
              $(this).next(".word_right").find("input.left").doVal("add", yellowBallId);
              return false;
            }
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
            $question.find(".answers .word_left").each(function(){
              var answerId = $(this).find("span").text().trim().slice(5);
              if(greyBallId ==  answerId){
                $(this).next(".word_right").find("input.left").doVal("sub", yellowBallId);
                return false;
              }

            });
          }
        }

        function resetToolTip(){
          $toolTip.hide();
          $toolTipDele.unbind( "click", deleHandle );
          paper.forEach(function (el) {
            el.attr("stroke-dasharray", "");
          });
        }

        function stringToObject(str) {
          return eval("(" + str + ")");
        }

        });

    })();
    (function DragAndDop(){
      $("#submit_quiz_form .question.dragAndDrop_question").each(function(){
        var $blueText = $(this).find(".blueText");
        var $select = $blueText.find(".ui-selectmenu");
        var $receive = $("<div class='receive'></div>");
        var $drag = $(this).find(".dragging li span");
        $(this).find(".dragging li")
          .droppable({
            accept: ".receive .ui-draggable",
            activeClass: "ui-state-highlight"
          });
        $drag.draggable({
          revert: true
        });

        $select.each(function(){
          $(this).hide()
            .parent("span")
            .after($receive.clone());
        });

        $(this).find(".receive").each(function(){
          $(this).droppable({
            accept: $drag,
            activeClass: "ui-state-highlight",
            drop: function( event, ui ) {
              var text = ui.draggable.text().trim();
              var $drag = ui.draggable;
              var answerId = ui.draggable.attr("answerId");
              var $select = $(this).prev().prev("select");
              var $span = $("<span></span>").text(text).attr("answerid",answerId)
                .draggable({
                  stop: function( event, ui ) {
                    $(this).remove();
                    $select.find("option:gt(0)").remove();
                    $drag.show();
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
    $.fn.doVal = function(type, yellowId) {
      var inputVal = $(this).val();
      inputVal = inputVal == "0" ? "" : inputVal;
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
    /*$.fn.rotate = function(num) {
      this.css({
        transform: "rotate(" + num + "deg)",
        "-webkit-transform": "rotate(" + num + "deg)",
        "-o-transform": "rotate(" + num + "deg)",
        "-ms-transform": "rotate(" + num + "deg)"
      });
      return this;
    };*/

  });


});


