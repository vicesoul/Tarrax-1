define [
  'jquery'
  'underscore'
  'jqueryui/dialog'
], ($, _) ->
  PickupUsers =
    dialog       : $('#pickup_users')
    insertButton : $("#pickup_users .insert_users")

    init: (h)->
      _.extend @, h

      @bindUIActions()
      @dialog.dialog(
        autoOpen: false
        width: '90%'
      )

    open: ->
      @dialog.dialog "open"

    close: ->
      @dialog.dialog "close"

    checked: ->
      @dialog.find('.search_users').contents().find('table.main-list tbody').find(':checked')

    insertClick: ->
      # do nothing by default, should be overrided

    bindUIActions: ->
      @insertButton.click =>
        @insertClick()
        @close()

  @PickupUsers = PickupUsers
