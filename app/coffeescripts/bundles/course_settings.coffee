require [
  'compiled/views/course_settings/NavigationView'
  'compiled/views/course_settings/UserCollectionView'
  'compiled/collections/UserCollection'
  'compiled/pickup_users'
  'compiled/pickup_teachers'
  'compiled/views/course_settings/CourseColumnsView'
  'compiled/views/course_settings/tabs/tabUsers'
  'vendor/jquery.cookie'
  'course_settings'
  'external_tools'
  'grading_standards'
], (NavigationView, UserCollectionView, UserCollection, PickupUsers, PickupTeachers) ->

  nav_view = new NavigationView
    el: $('#tab-navigation')

  loadUsersTab = ->
    window.app = usersTab: {}
    for baseRole in ENV.ALL_ROLES
      eType = baseRole.label.toLowerCase()
      window.app.usersTab["#{eType}sView"] = new UserCollectionView
        el: $("##{eType}_enrollments")
        url: ENV.USERS_URL
        count: baseRole.count
        requestParams:
          enrollment_role: baseRole.base_role_name

      for customRole in baseRole.custom_roles
        continue if customRole.workflow_state == 'inactive' && customRole.count == 0
        window.app.usersTab["#{customRole.asset_string}sView"] = new UserCollectionView
          el: $("##{customRole.asset_string}")
          url: ENV.USERS_URL
          count: customRole.count
          requestParams:
            enrollment_role: customRole.name

  $ ->
    nav_view.render()

    if $("#tab-users").is(":visible")
      loadUsersTab()

    $("#course_details_tabs").bind 'tabsshow', (e,ui) ->
      if ui.tab.hash == '#tab-users' and not window.app?.usersTab
        loadUsersTab()

    PickupUsers.init
      insertClick: ->
        emails = @checked().map (index, el)->
          $(el).data('user_email') + "\n"
        .get().join ''

        $area = $("#user_list_textarea_container .user_list")
        $area.val( $area.val() + emails )

    PickupTeachers.init
      insertClick: ->
        emails = @checked().map (index, el)->
          $(el).data('email') + "\n"
        .get().join ''

        $area = $("#user_list_textarea_container .user_list")
        $area.val( $area.val() + emails )

    $(document).on 'click', "#pick_up_from_accounts", ->
      PickupUsers.open()
    .on 'click', '#pick_up_from_teachers_bank', ->
      PickupTeachers.open()

