require [
  "jquery"
], ($) ->
	$ ->
		$mainList = $("table.main-list")
		$masterCheckbox = $mainList.find("input.master_checkbox")
		$subCheckbox = $mainList.find("input.sub_checkbox")

		$masterCheckbox.change ->
			flag = $(this).prop "checked"
			$subCheckbox.prop "checked", flag
    
		$("div.tree input:checkbox").change ->
      $closureCheckbox = $(this).closest("div").next("div")
      flag = $(this).prop "checked"
      $closureCheckbox.find("input:checkbox").prop "checked", flag if $closureCheckbox.find("div").size() isnt 0

    $("div.tree i.ui-icon").click ->
    	$closureCheckbox = $(this).closest("div").next("div")
    	if $closureCheckbox.find("div").size() isnt 0
	    	$closureCheckbox.toggle()
	    	if $(this).is(".ui-icon-circle-triangle-e")
	    		$(this).removeClass("ui-icon-circle-triangle-e").addClass("ui-icon-circle-triangle-s")
    		else
    			$(this).removeClass("ui-icon-circle-triangle-s").addClass("ui-icon-circle-triangle-e")