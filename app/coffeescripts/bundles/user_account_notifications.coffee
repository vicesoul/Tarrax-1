
require [
  'jquery'
  'jquery.dataTables.js'
],($) ->
  
  $ ->
    $(".jxbTable").dataTable(
      #"aaSorting" : [[ 4, "desc" ]]
      "bProcessing": true
      "sAjaxSource": '/users/1/account_notifications.json'
      "bServerSide": true
      "aaSorting": []
      "bFilter": false
    )
