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
  'quizzes_new',
  'bootstrap'
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

  Global.quizzes.quizzesShow();

});

});
