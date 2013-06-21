
require [
  'jquery'
  '/themes/jiaoxuebang/javascripts/jquery.dataTables.js'
],($) ->
  
  $ ->
    $(".jxbTable").dataTable(
      #"aaSorting" : [[ 4, "desc" ]]
      "bProcessing": true
      "sAjaxSource": 'http://lvh.me:3000/users/1/account_notifications.json'
      "bServerSide": true
      "aaSorting": []
      "bFilter": false
    )
