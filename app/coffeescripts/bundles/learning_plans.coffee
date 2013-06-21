require [
  'jquery'
  'underscore'
  'compiled/fn/preventDefault'
  'compiled/pickup_users'
  'i18n!learning_plans'
  'jquery.instructure_date_and_time'
  'compiled/jquery/validate'
  'vendor/jqueryui/effects/highlight'
], ($, _, preventDefault, PickupUsers, I18n) ->

  # learning plans index page
  $(document).on 'click', '.publish, .revert', preventDefault ->
    if confirm I18n.t('are_you_sure', 'Are you sure?')
      $(this).spin()
      $.ajax
        url: $(this).attr 'href'
        type: 'post'
        data: {_method: 'put'}
        success: (data)=>
          tr = $(this).closest('tr')
          tr.replaceWith data
          tr.find('td').effect 'highlight', {}, 'slow'

  # show course selection dialog
  .on 'click', '#pickup_courses_link', preventDefault ->
    $('.pickup_course').dialog
      width: '800px'
      title: $('.pickup_course').data('title')

  #remove user or course from list
  .on "click", '.remove_course_link, .remove_user_link', preventDefault ->
    if confirm I18n.t('are_you_sure', "Are you sure?")
      $(this).prev().val('1')
      $(this).closest('tr').hide 'highlight', {}, 'slow'

  # pick course and close dialog
  # search form submit action
  .on 'submit', '.search-form', preventDefault ->
    $('.course_selection').spin()
    $.ajax
      url: $(this).attr('action')
      data: $(this).serialize()
      success: (data)->
        $('.course_selection').html(data)
  # controls for course selection
  $(document).on 'click', '.add', ->
    $('#courses option:selected').appendTo $('#selected_courses')
  .on 'click', '.add-all', ->
    $('#courses option').appendTo $('#selected_courses')
  .on 'click', '.delete', ->
    $('#selected_courses option:selected').each ->
      $(this).appendTo $ "#courses optgroup[label=#{$(this).data('optgroup')}]"
  .on 'click', '.delete-all', ->
    $('#selected_courses option').each ->
      $(this).appendTo $ "#courses optgroup[label=#{$(this).data('optgroup')}]"
  .on 'click', '.pickup_course .btn-cancel', ->
    $('.pickup_course').dialog('close')
  .on 'click', '.pickup_course .insert-course', preventDefault ->
    link = $('.course_wrap .add_fields')
    time = new Date().getTime()
    regexp = new RegExp link.data('id'), 'g'
    ids = $('.course_list .course_id').map (index, id)->
      $(id).val()
    teachers_data = $('.courses_data').data('teachers')
    for course in $("#selected_courses option")
      id = $(course).val()
      unless _.contains ids, id
        name = $(course).text()
        new_course = $ link.data('fields').replace regexp, time + _.uniqueId()
        new_course.find('.course_id').val id
        teachers = teachers_data[id]
        new_course.prepend """
                           <td>#{name}</td>
                           <td>#{teachers.join ','}</td>
                           """
        $('table.course_list').append new_course
    $('.pickup_course').dialog('close')


  # show users selection dialog
  .on 'click', '#pickup_users_link', preventDefault ->
    PickupUsers.open()

  $ ->
    $('#courses option').each ->
      $(this).data 'optgroup', $(this).parent().attr('label')

    $('.date_field').date_field()


    # pickup user dialog initialization
    PickupUsers.init
      insertClick: ->
        # ref http://railscasts.com/episodes/197-nested-model-form-part-2
        link = $('.user_wrap .add_fields')
        time = new Date().getTime()
        regexp = new RegExp link.data('id'), 'g'
        ids = $('.user_list .user_id').map (index, id)->
          $(id).val()

        for checkbox in @checked()
          id = $(checkbox).val()
          unless _.contains ids, id
            user_name = $(checkbox).data 'user_name'
            accounts = $(checkbox).data('accounts')
            job_positions = $(checkbox).data('positions')

            new_user = $ link.data('fields').replace regexp, time + _.uniqueId()
            new_user.find('.user_id').val id
            new_user.prepend """
                               <td>#{user_name}</td>
                               <td>#{accounts}</td>
                               <td>#{job_positions}</td>
                             """
            $('table.user_list').append new_user
