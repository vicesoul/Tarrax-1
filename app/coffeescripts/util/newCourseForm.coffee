define [
  'jquery'
  'i18n!validate_course_form'
  'jquery.disableWhileLoading'
], ($, I18n) ->

  newCourseForm = ->
    changeEvents = 'change keyup input'
    showCourseCodeIfNeeded = ->
      if $nameInput.val().trim().length > 20
        $nameInput.unbind changeEvents, showCourseCodeIfNeeded
        $('#course_code_wrapper').slideDown('fast')

    $nameInput = $('#new_course_form [name="course[name]"]')
    $nameInput.bind changeEvents, showCourseCodeIfNeeded

    $('#new_course_form').submit -> 
      unless $nameInput.val() 
        alert I18n.t('errors.invalid_course_name', "Please add a course name")
        return false
      unless $('#course_course_category_id').val()
        alert I18n.t('errors.invalid_course_category', "Please select a course category")
        return false
      $(this).disableWhileLoading($.Deferred())
