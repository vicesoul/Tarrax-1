define [
  'jquery'
  'underscore'
  'Backbone'
  'compiled/fn/preventDefault'
  'i18n!course_column'
  'jst/courses/settings/LineColumnView'
  'jst/courses/settings/EditCourseColumnView'
  'compiled/jquery/richeditor'
  'compiled/jquery.rails_flash_notifications'
], ($, _, Backbone, preventDefault, I18n, lineColumnTemplate, columnTemplate) ->

  class CourseColumn extends Backbone.Model
    defaults:
      slug: ''
      name: I18n.t('default_column_name', 'Course Column Name')
    resourceName: 'course_columns'

    toJSON: ->
      _.extend { course_column: @attributes }, @attributes # wrap attributes in model name for communicating with rails

  class CourseColumnCollection extends Backbone.Collection
    model: CourseColumn

  columnList = new CourseColumnCollection

  class TabColumnsView extends Backbone.View
    el: $('#course_columns')
    elListView: $('#course_columns .list_view')
    elEditView: $('#course_columns .edit_view')

    events:
      'click .add_column': 'addColumn'
      'click .remove, .list': 'listColumns'

    initialize: ->
      columnList.on 'reset', @addAll, @
      columnList.on 'add', @addOne, @
      @on 'edit', @editColumn
      @editView = new EditColumnView
        el: @elEditView

      @render()

    addOne: (model)->
      view = new LineColumnView
        model: model
        tabView: @
      @$el.find('tbody').append view.render().el

    addAll: ->
      columnList.each @addOne, @

    addColumn: preventDefault ->
      @editColumn()

    listColumns: preventDefault ->
      @editing = false
      @render()

    editColumn: (model)->
      @editing = true
      @render()

      @editView.change model ? new CourseColumn

    render: ->
      if @editing
        @elEditView.show()
        @elListView.hide()
      else
        @elEditView.hide()
        @elListView.show()

  class LineColumnView extends Backbone.View
    tagName: 'tr'

    initialize: (options)->
      @tabView = options.tabView
      @model.on 'destroy', @remove, @

    events:
      'click .modify': 'edit'
      'click .remove': 'removeColumn'

    edit: ->
      @tabView.trigger "edit", @model
      false

    removeColumn: ->
      if confirm I18n.t('are_you_sure', 'Are your sure?')
        @model.destroy()

    render: ->
      @$el.html lineColumnTemplate @model.toJSON()
      @

  class EditColumnView extends Backbone.View
    events:
      'click .remove': 'removeColumn'
      'click .submit': 'saveColumn'

    removeColumn:  ->
      if confirm I18n.t('are_you_sure', 'Are your sure?')
        @model.destroy()

    saveColumn: ->
      tinyMCE.triggerSave()

      # save all default columns for the first time
      columnList.each (model)=>
        model.save() if model.isNew() and model.get('slug') != '' and model != @model

      @model.set(
        slug: @model.get 'slug'
        name: @$el.find('.name').val()
        content: @$el.find('.content').val()
      )

      isNew = @model.isNew()

      @$el.spin()

      options =
        success: =>
          $.flashMessage I18n.t('flash.columns', 'Course Column successfully saved.')
          @render() if isNew # rerender to show `remove` button
        error: ->
          $.flashError I18n.t('flash.columnsError', "Something went wrong updating the course's column. Please try again later.")
        complete: =>
          @$el.spin(false)


      if isNew
        columnList.create @model, options
      else
        @model.save {}, options

      false

    change: (model)->
      @model = model
      @render()

    render: ->
      @$el.html columnTemplate @model.toJSON()
      @$el.find('.content').richEditor()
      @

  $ ->
    columnsView = new TabColumnsView
    columnsData = $('#course_columns').data('columns')
    if columnsData.length > 0
      columnList.reset columnsData
    else
      columnList.reset ENV['college_course_columns']
