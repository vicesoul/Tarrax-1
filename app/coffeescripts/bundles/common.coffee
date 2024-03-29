require [
  # true modules that we manage in this file
  'Backbone'
  'compiled/widget/courseList'
  'compiled/helpDialog'

  # modules that do their own thing on every page that simply need to
  # be required
  'translations/_core'
  'jquery.ajaxJSON'
  'vendor/firebugx'
  'jquery.google-analytics'
  'vendor/swfobject/swfobject'
  'reminders'
  'jquery.instructure_forms'
  'instructure'
  'ajax_errors'
  'page_views'
  'compiled/license_help'
  'compiled/behaviors/ujsLinks'
  'compiled/behaviors/admin-links'
  'compiled/behaviors/elementToggler'
  # uncomment these to turn on collection pinning and voting
  # 'compiled/behaviors/upvote-item'
  # 'compiled/behaviors/repin-item'
  # 'compiled/behaviors/follow'
  'compiled/behaviors/tooltip'
  'compiled/behaviors/instructure_inline_media_comment'

  # other stuff several bundles use
  'media_comments'
  # add mwEmbedLoader 2012-11-01 rupert
  # 'mwEmbedLoader'
  'order'
  'jqueryui/effects/drop'
  'jqueryui/progressbar'
  'jqueryui/tabs'
  'compiled/registration/incompleteRegistrationWarning'

  # random modules required by the js_blocks, put them all in here
  # so RequireJS doesn't try to load them before common is loaded
  # in an optimized environment
  'jquery.fancyplaceholder'
  'jqueryui/autocomplete'
  'link_enrollment'
  'media_comments'
  'vendor/jquery.pageless'
  'vendor/jquery.scrollTo'
  'compiled/badge_counts'
], (Backbone, courseList, helpDialog) ->
  courseList.init()
  helpDialog.initTriggers()

  # Make the font-based icons work in IE8,
  # it needs to be told to redraw pseudo elements on page load
  if INST.browser.ie8
    $('<style>:before,:after{content:"" !important}</style>').appendTo('head').delay(1).remove()

  $('#skip_navigation_link').on 'click', ->
    $($(this).attr('href')).attr('tabindex', -1).focus()

  # TODO: remove this code once people have had time to update their logo-related
  # custom css. see related code in app/stylesheets/base/_#header.sass.
  # $logo = $('#header-logo')
#   if $logo.length > 0 and $logo.css('background-image').match(/\/canvas\/header_canvas_logo\.png/)
#     $logo.addClass('original')

  ##
  # Backbone routes
  $('body').on 'click', '[data-pushstate]', (event) ->
    event.preventDefault()
    Backbone.history.navigate $(this).attr('href'), yes

