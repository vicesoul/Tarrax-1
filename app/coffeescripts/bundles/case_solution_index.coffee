
require [
  'jquery'
  'jqueryui/dialog'
  'jqueryui/easyDialog'
], ($) ->

  $(document).ready(->

    $('.admin-link-hover-area').each(->
      $(this).remove() if $(this).find('li').size() < 1
    )

    $('.solution-submit').bind('click', ->
      _this = this
      if $.trim($(_this).attr('solution_title')) == ''
        $('<div></div>').easyDialog({
          content: '请您编辑完解决方案后再提交！'
        })
      else
        $('<div></div>').easyDialog({
          content: '您确定要提交该案例解决方案吗？'
          confirmButtonClass: 'btn-primary'
          confirmCallback: ->
            $.get(_this.href, (data)->
              if data
                $('<div></div>').easyDialog({
                  content: '提交案例解决方案成功！'
                  closeCallback: ->
                    window.location.reload()
                })
              else
                $('<div></div>').easyDialog({
                  content: '提交案例解决方案失败！'
                })
              
            )
        }, 'confirm')
      return false
    )

    $('.solution-review').bind('click' , ->
        _this = this
        $('#case-review-dialog').easyDialog({
          confirmButtonClass: 'btn-primary'
          confirmCallback: ->
            $.get(_this.href + '?review_result=' + $('#case-review-dialog input:checked').val(), (data)->
              if data
                $('<div></div>').easyDialog({
                  content: '审批案例解决方案成功！'
                  closeCallback: ->
                    window.location.reload()
                })

              else
                $('<div></div>').easyDialog({
                  content: '审批案例解决方案失败！'
                })
            )
        }, 'confirm')
        return false
      )

  )
