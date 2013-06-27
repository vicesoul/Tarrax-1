define [
  'jquery'
  'underscore'
  'jqueryui/dialog'
], ($, _) ->
  PickupTeachers =
    dialog       : $('#pickup_teachers')
    insertButton : $("#pickup_teachers .insert_teachers")

    init: (h)->
      _.extend @, h

      @bindUIActions()
      @dialog.dialog(
        autoOpen: false
        width: '80%'
      )

    open: ->
      @dialog.dialog "open"

    close: ->
      @dialog.dialog "close"

    checked: ->
      @dialog.find('iframe').contents().find('table td').find(':checked')

    insertClick: ->
      # do nothing by default, should be overrided

    bindUIActions: ->
      @insertButton.click =>
        @insertClick()
        @close()
