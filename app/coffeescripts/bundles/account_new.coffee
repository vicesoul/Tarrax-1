require [
  'underscore'
  'i18n!account'
  'compiled/fn/preventDefault'
  'compiled/models/Account'
  'compiled/object/flatten'
  'jquery.instructure_forms'
], (_, I18n, preventDefault, Account, flatten ) ->

  accountErrors = (errors) ->
    flatten
      account: Account::normalizeErrors(errors)
    , arrays: false

  $form = $('#new_account')
  promise = null
  $form.formSubmit
    beforeSubmit: ->
      promise = $.Deferred()
      $form.disableWhileLoading(promise)
    success: (data) =>
      window.location = "/accounts/#{data.id}/redirect"
    formErrors: false
    error: (errors) ->
      promise.reject()
      $form.formErrors accountErrors(errors)
      $('a.captcha_change_code').trigger('click') # validation code avaliable once only

  $('a.captcha_change_code').click preventDefault ->
    $.get(this.href + '?object=account')
      .done (data)->
        src = $(data).find("img").attr("src")
        $('#simple_captcha').find("img").attr("src", src)
        

