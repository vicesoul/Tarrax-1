require [
  'jquery'
  'underscore'
  'compiled/fn/preventDefault'
], ($, _, preventDefault) ->
  $('.list-controls').on 'click', '.add', ->
    $('#courses option:selected').appendTo $('#rank')
    update_courses()
  .on 'click', '.add-all', ->
    $('#courses option').appendTo $('#rank')
    update_courses()
  .on 'click', '.delete', ->
    $('#rank option:selected').appendTo $('#courses')
    update_courses()
  .on 'click', '.delete-all', ->
    $('#rank option').appendTo $('#courses')
    update_courses()

  # save rank courses list for submit
  update_courses = ->
    curr = $('.rank').data 'curr'
    $("#course_system_attributes_#{curr}").html $('#rank').html()

  # listen on radio change event
  $('.rank').on 'change', 'input:radio', ->
    # save current radio val
    prev = $('.rank').data 'curr'
    curr = $(this).val()
    $('.rank').data 'curr', curr

    update_courses if prev
    $('#rank').html $("#course_system_attributes_#{curr}").html()

  # select first radio by default
  $ ->
    $('.rank input:radio:first').click()

  # set course_system info before submit
  $('.rank-form').submit ->
    form = $('.rank-form')
    form.find('#course_system_attributes_account_id').val $('#search_account_id ').val()
    form.find('#course_system_attributes_job_position_id').val $('#search_job_position_id').val()
    form.find('#course_system_attributes_course_category_ids').append $('#search_course_category_ids option:selected').clone()
    form.find('option').attr('selected', 'selected')
    true
