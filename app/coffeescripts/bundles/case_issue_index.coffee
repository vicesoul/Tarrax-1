
require [
  'jquery'
  'jqueryui/dialog'
  'jqueryui/easyDialog'
], ($) ->

  $(document).ready(->
    $('.issue-submit').bind('click', ->
      _this = this
      $('<div></div>').easyDialog({
        content: '您确定要提交该案例问题吗？'
        confirmButtonClass: 'btn-primary'
        confirmCallback: ->
          $.get(_this.href, (data)->
            if data
              $('<div></div>').easyDialog({
                content: '提交案例问题成功！'
                closeCallback: ->
                  window.location.reload()
              })
            else
              $('<div></div>').easyDialog({
                content: '提交案例问题失败！'
              })
            
          )
      }, 'confirm')
      return false
    )

    $('.issue-review').bind('click' , ->
        _this = this
        $('#case-review-dialog').easyDialog({
          confirmButtonClass: 'btn-primary'
          confirmCallback: ->
            $.get(_this.href + '?review_result=' + $('#case-review-dialog input:checked').val(), (data)->
              if data
                $('<div></div>').easyDialog({
                  content: '审批案例问题成功！'
                  closeCallback: ->
                    window.location.reload()
                })

              else
                $('<div></div>').easyDialog({
                  content: '审批案例问题失败！'
                })
            )
        }, 'confirm')
        return false
      )

    $('.issue-apply').bind('click' , ->
        _this = this
        $('#case-apply-dialog').easyDialog({
          confirmButtonClass: 'btn-primary'
          confirmCallback: ->
            $.get(_this.href + '?group_discuss=' + $('#case-apply-dialog input:checked').val(), (data)->
              if data
                $('<div></div>').easyDialog({
                  content: '申领案例成功！'
                  closeCallback: ->
                    window.location.reload()
                })

              else
                $('<div></div>').easyDialog({
                  content: '申领失败！请确认您没重复申领'
                })
            )
        }, 'confirm')
        return false
      )
  )
