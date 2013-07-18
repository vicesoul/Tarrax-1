
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

      $('.issue-push').bind('click' , ->
        _this = this
        $('#knowledge-base-dialog').easyDialog({
          confirmButtonClass: 'btn-primary'
          confirmCallback: ->
            $.get(_this.href + '?knowledge_base_id=' + $('#knowledge_base_id').val(), (data)->
              if data
                $('<div></div>').easyDialog({
                  content: '录入至知识库成功！'
                  closeCallback: ->
                    window.location.reload()
                })
              else
                $('<div></div>').easyDialog({
                  content: '录入至知识库失败！'
                })
            )
        }, 'confirm')
        return false
      )

    $('.issue-apply').bind('click' , ->
        _this = this
        if $('#case-apply-dialog input:checked').val() is 'true'
          $('#case-apply-group-name input').val($(_this).attr('issue_subject')+"讨论组").parent().show()
        else
          $('#case-apply-group-name').hide()
        $('#case-apply-dialog').easyDialog({
          confirmButtonClass: 'btn-primary'
          confirmCallback: ->
            $.get(_this.href + '?group_discuss=' + $('#case-apply-dialog input:checked').val()+'&group_name='+$('#case-apply-group-name input').val(), (data)->
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

    $('#case-apply-dialog input[type=radio]').bind('click', ->
      if $(this).val() is 'true'
        $('#case-apply-group-name').show()
      else
        $('#case-apply-group-name').hide()
    )

  )
