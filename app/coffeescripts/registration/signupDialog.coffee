define [
  'underscore'
  'i18n!registration'
  'compiled/fn/preventDefault'
  'compiled/registration/registrationErrors'
  'compiled/models/User'
  'compiled/models/Pseudonym'
  'jst/registration/studentDialog'
  'jst/registration/studentHigherEdDialog'
  'compiled/object/flatten'
  'jquery.instructure_forms'
  'jquery.instructure_date_and_time'
], (_, I18n, preventDefault, registrationErrors, User, Pseudonym, studentDialog, studentHigherEdDialog, flatten) ->

  $nodes = {}
  templates = {
  studentDialog,
  studentHigherEdDialog
  }
  tabChange = (title, content) ->
    $(content).not(":first").hide().end().eq(0).show()
    $(title).eq(1).addClass("button").show()
    $(title).each (i) ->
      $(this).click (e) ->
        $(title).addClass("button")
        $(this).removeClass("button")
        $(content).hide()
        $(content).eq(i).show()
        e.preventDefault()

  tabChange(".register .nav-tabs li", ".register .tab-content > div")

  signupDialog = (id, title, i) ->

    return unless templates[id]
    $node = $nodes[id] ?= $('<div />')
    $node.html templates[id]()
    $node.find('.date-field').datetime_field()
    $node.find('.signup_link').click preventDefault ->
      $node.dialog('close')
      signupDialog($(this).data('template'), $(this).prop('title'))

    $form = $node.find('form')
    promise = null
    $form.formSubmit
      beforeSubmit: ->
        promise = $.Deferred()
        $form.disableWhileLoading(promise)
      success: (data) =>
        # they should now be authenticated (either registered or pre_registered)

        if data.course
          window.location = "/courses/#{data.course.course["id"]}?registration_success=1"
        else
          window.location = "/?registration_success=1"
      formErrors: false
      error: (errors) ->
        promise.reject()
        $form.formErrors registrationErrors(errors)

    ###$node.dialog
      resizable: false
      title: title
      width: 550
      open: ->
        $(this).find('a').eq(0).blur()
        $(this).find(':input').eq(0).focus()
      close: -> $('.error_box').filter(':visible').remove()###
    $(".tab-content .tab-pane").eq(i).append $node.addClass "notdd"
    #$node.fixDialogButtons()
  signupDialog("studentHigherEdDialog", "ddd", 0)
  signupDialog("studentDialog", "ddd", 1)
