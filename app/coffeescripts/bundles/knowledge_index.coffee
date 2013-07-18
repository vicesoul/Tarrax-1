
require [
  'jquery'
  'jqueryui/dialog'
  'jqueryui/easyDialog'
], ($) ->

  $(document).ready(->

    $('.admin-link-hover-area').each(->
      $(this).remove() if $(this).find('li').size() < 1
    )

    $('.issue-submit').bind('click', ->
      _this = this
      $('<div></div>').easyDialog({
        content: '您确定要提交该知识吗？'
        confirmButtonClass: 'btn-primary'
        confirmCallback: ->
          $.get(_this.href, (data)->
            if data
              $('<div></div>').easyDialog({
                content: '提交知识成功！'
                closeCallback: ->
                  window.location.reload()
              })
            else
              $('<div></div>').easyDialog({
                content: '提交知识失败！'
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
                  content: '审批知识成功！'
                  closeCallback: ->
                    window.location.reload()
                })

              else
                $('<div></div>').easyDialog({
                  content: '审批知识失败！'
                })
            )
        }, 'confirm')
        return false
      )

  )
