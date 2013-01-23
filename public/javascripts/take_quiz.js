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
  'i18n!editor'
], function(I18n, $, timing, autoBlurActiveInput, tinymce) {

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

    var ipadInputType = (function (){

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

    var takePaintQuestion = (function(){
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

    var takeConnectingLeadQuestion = (function(){
      if( $(".question.connecting_lead_question").size() === 0 ) return false;

      $.fn.rotate = function(num) {
        this.css({
          transform: "rotate(" + num + "deg)",
          "-webkit-transform": "rotate(" + num + "deg)",
          "-o-transform": "rotate(" + num + "deg)",
          "-ms-transform": "rotate(" + num + "deg)"
        });

        return this;
      };

      $("#submit_quiz_form .connecting_lead_question").each(function(){
        var readyLine,
            deleHandle,
            $answers = $(this).find(".answers"),
            $toolTip = $("<div><h5>是否删除？</h5></div>")
              .addClass("tool-tip")
              .hide()
              .bind("click", function(e){
                e.stopPropagation();
              }).appendTo( $answers ),
            $toolTipDele = $("<button type=button>确认</button>").appendTo($toolTip),
            $toolTipCancel = $("<button type=button>取消</button>").bind("click", function(){
              resetToolTip();

            }).appendTo($toolTip),
            paper = Raphael( $answers[0], $answers.width(), $answers.height()),
            $this = $(this);

        function drawLine( $end ){
          var $active = $this.find( ".active" );
          var $towNOde = $end.add( $active );
          var checkName;

          checkName = $end.is(".word_left") || $active.is(".word_left") ? "leftSelected" : "rightSelected";
          $towNOde.addClass( checkName );

          var x1,y1,x2,y2;
          var normalPosition = $end.position().left > $active.position().left;
          var $nodeB = normalPosition ? $end : $active;
          var $nodeA = !normalPosition ? $end : $active;
          x2 = $nodeB.position().left - 10;
          y2 = $nodeB.position().top + $nodeB.height()/2 + 5;

          x1 = $nodeA.position().left + $nodeA.width() + 10;
          y1 = $nodeA.position().top + $nodeA.height()/2 + 5;

          var line = paper.path("M" + x1 + " " + y1 + "L" + x2 + " " + y2);
          line.attr({
            "stroke": "#08c",
            "stroke-width": 5
          }).click(function(e){
            e.stopPropagation();
            resetToolTip();
            this.attr({
              "stroke-dasharray": "-"
            });
            $toolTip.show()
              .css({
                left: ( x1 + x2 )/2 - $toolTip.width()/2,
                top: ( y1 + y2 )/2 - $toolTip.height() * 1.5
              });
            deleHandle =  deleLine(this, $towNOde, checkName, $toolTip);
            $toolTipDele.bind( "click", deleHandle );
          });

        }

        function deleLine(line, leads, className, toolTip){
          return function(){
            line.remove();
            leads.removeClass( className );
            toolTip.hide();
          }
        }

        function resetToolTip(){
          $toolTip.hide();
          $toolTipDele.unbind( "click", deleHandle );
          paper.forEach(function (el) {
            el.attr("stroke-dasharray", "");
          });
        }

        $(document).click(function(){
          resetToolTip();
        });

        $(this).find(".connecting_lead").each( function( i ){

          $(this).css({
            position: "absolute",
            left: 280 * (i%3),
            top: 40 * Math.floor(i/3)
          });

          $answers.css({
             height: 40 * Math.ceil(i/3)
          });

          $(this).bind( "click", function(){

            if( $(this).is(".word_center") && $(this).is(".leftSelected") && $(this).is(".rightSelected")
             || $(this).is(".word_left") && $(this).is(".leftSelected")
             || $(this).is(".word_right") && $(this).is(".rightSelected")
              )
            return;

            var thisLine = i%3;
            if( readyLine === undefined ) {
              $(this).addClass("active");
              readyLine = thisLine;

            }else if( readyLine != undefined && Math.abs( readyLine - thisLine ) !== 1 ) {

              if( $(this).is( ".active" ) ){
                readyLine = undefined;
              }else{
                $(this).closest( ".answers" ).find( ".active").toggleClass( "active" );
              }
              $(this).toggleClass( "active" );

            }else{

              drawLine( $(this) );
              $(this).closest( ".answers" ).find( ".active").toggleClass( "active" );
              readyLine = undefined;

            }
          });
        });

        $(this).bind( "mousedown", function(){
          return false;
        });

      });
    })();


  });
});


