define [
  'underscore'
  'i18n!registration'
  'compiled/fn/preventDefault'
  'compiled/models/User'
  'compiled/models/Pseudonym'
  'jst/registration/studentDialog'
  'jst/registration/haveACode'
  'jst/registration/haveCodeNot'
  'compiled/object/flatten'
  'jquery.instructure_forms'
  'jquery.instructure_date_and_time'
], (_, I18n, preventDefault, User, Pseudonym, studentDialog, haveACode, haveCodeNot, flatten) ->

  $nodes = {}
  templates = {
  #studentDialog,
  haveACode,
  haveCodeNot
  }
  tabChang = (title, content) ->
    $(content).not(":first").hide().end().eq(0).show()
    $(title).eq(0).addClass("active").show()
    $(title).each (i) ->
      $(this).click (e) ->
        $(title).removeClass("active")
        $(this).addClass("active")
        $(content).hide()
        $(content).eq(i).show()
        e.preventDefault()

  tabChang(".register .nav-tabs li", ".register .tab-content > div")

  signupDialog = (id, title, i) ->
    return unless templates[id]
    $node = $nodes[id] ?= $('<div />')
    $node.html templates[id](
      terms_url: "http://www.instructure.com/terms-of-use"
    )
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
        window.location = "/?login_success=1&registration_success=1"
      formErrors: false
      error: (errors) ->
        promise.reject()
        if _.any(errors.user.birthdate ? [], (e) -> e.type is 'too_young')
          $node.find('.registration-dialog').html I18n.t('too_young_error', 'You must be at least %{min_years} years of age to use Canvas without a course join code.', min_years: ENV.USER.MIN_AGE)
          $node.dialog buttons: [
            text: I18n.t('ok', "OK")
            click: -> $node.dialog('close')
            class: 'btn-primary'
          ]
          return
        errors = flatten
          user: User::normalizeErrors(errors.user)
          pseudonym: Pseudonym::normalizeErrors(errors.pseudonym)
          observee: Pseudonym::normalizeErrors(errors.observee)
        , arrays: false
        if errors['user[birthdate]']
          errors['user[birthdate(1)]'] = errors['user[birthdate]']
          delete errors['user[birthdate]']
        $form.formErrors errors

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

