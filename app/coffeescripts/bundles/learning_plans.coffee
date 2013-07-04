require [
  'jquery'
  'underscore'
  'compiled/fn/preventDefault'
  'compiled/pickup_users'
  'i18n!learning_plans'
  'jquery.instructure_date_and_time'
  'compiled/jquery/validate'
  'vendor/jqueryui/effects/highlight'
  'vendor/jquery.tree'
], ($, _, preventDefault, PickupUsers, I18n) ->

  # learning plans index page
  $(document).on 'click', '.revert', preventDefault ->
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
      $(this).closest('tr').addClass('hide')

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

  .on 'click', '.account_tree_dialog .btn-cancel', ->
    $('.account_tree_dialog').dialog('close')

  # show account tree dialog when publish clicked
  .on 'click', '.publish', preventDefault ->
    # open account tree dialog for course section decision
    $('.tree-form').attr 'action', $(this).attr('href') # save current url
    $('.tree-form').data 'id', $(this).closest('tr').data('id') # save current id

    tree_json = $(this).closest('tr').data('tree')
    #tree_data = buildTree if tree_json.children.length > 0 then tree_json.children else [ tree_json ]
    tree_data = buildTree [ tree_json ]
    tree = $('<div class="tree_wrap"></div>').append tree_data
    tree.tree
        ui:
          theme_name: 'checkbox'
        plugins:
          checkbox: {}

    dialog = $('.account_tree_dialog')
    dialog.find('.tree_wrap').remove() # reset html
    dialog
      .prepend(tree)
      .dialog
        title: I18n.t('pickup_section_names', "Pick up Section Names")
        width: '500px'


  # recursive way to build account tree
  buildTree = (collection)->
    ul = $('<ul></ul>')
    for obj in collection
      li = $("<li class='open'><a href='#' data-id='#{obj.id}'><ins>&nbsp;</ins>#{obj.name}</a></li>")
      li.append buildTree(obj.children) if obj.children.length > 0
      ul.append li
    ul

  # use selected account name as section's to publish plan
  $(document).on 'submit', '.tree-form', preventDefault ->
    # account selected as section names to publish
    account_ids = $('.account_tree_dialog').find('.checked, .undetermined').map (i, el)->
      $(el).data('id')

    $(this).spin()
    $.ajax
      url: $(this).attr 'action'
      type: 'post'
      data: {_method: 'put', section_mappings: account_ids.get()}
      success: (data)=>
        $(this).spin(false)
        $('.account_tree_dialog').dialog('close')
        tr = $("#tr_plan_#{$(this).data('id')}")
        tr.replaceWith data
        tr.find('td').effect 'highlight', {}, 'slow'

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
        ids = $('.user_list tr:not(.hide) .user_id').map (index, id)->
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
