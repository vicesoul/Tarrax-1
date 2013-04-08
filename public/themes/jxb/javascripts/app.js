require(["jquery", "/themes/jxb/javascripts/bootstrap.js", "/themes/jxb/javascripts/jquery.dataTables.js", "/javascripts/vendor/jqueryui/effects/slide.js"], function($){
$.fn.dataTableExt.oApi.fnPagingInfo = function ( oSettings ) {
	return {
		"iStart":         oSettings._iDisplayStart,
		"iEnd":           oSettings.fnDisplayEnd(),
		"iLength":        oSettings._iDisplayLength,
		"iTotal":         oSettings.fnRecordsTotal(),
		"iFilteredTotal": oSettings.fnRecordsDisplay(),
		"iPage":          Math.ceil( oSettings._iDisplayStart / oSettings._iDisplayLength ),
		"iTotalPages":    Math.ceil( oSettings.fnRecordsDisplay() / oSettings._iDisplayLength )
	};
}
$.extend( $.fn.dataTableExt.oPagination, {
	"bootstrap": {
		"fnInit": function( oSettings, nPaging, fnDraw ) {
			var oLang = oSettings.oLanguage.oPaginate;
			var fnClickHandler = function ( e ) {
				e.preventDefault();
				if ( oSettings.oApi._fnPageChange(oSettings, e.data.action) ) {
					fnDraw( oSettings );
				}
			};

			$(nPaging).addClass('pagination').append(
				'<ul>'+
					'<li class="prev disabled"><a href="#">&larr; '+oLang.sPrevious+'</a></li>'+
					'<li class="next disabled"><a href="#">'+oLang.sNext+' &rarr; </a></li>'+
				'</ul>'
			);
			var els = $('a', nPaging);
			$(els[0]).bind( 'click.DT', { action: "previous" }, fnClickHandler );
			$(els[1]).bind( 'click.DT', { action: "next" }, fnClickHandler );
		},

		"fnUpdate": function ( oSettings, fnDraw ) {
			var iListLength = 5;
			var oPaging = oSettings.oInstance.fnPagingInfo();
			var an = oSettings.aanFeatures.p;
			var i, j, sClass, iStart, iEnd, iHalf=Math.floor(iListLength/2);

			if ( oPaging.iTotalPages < iListLength) {
				iStart = 1;
				iEnd = oPaging.iTotalPages;
			}
			else if ( oPaging.iPage <= iHalf ) {
				iStart = 1;
				iEnd = iListLength;
			} else if ( oPaging.iPage >= (oPaging.iTotalPages-iHalf) ) {
				iStart = oPaging.iTotalPages - iListLength + 1;
				iEnd = oPaging.iTotalPages;
			} else {
				iStart = oPaging.iPage - iHalf + 1;
				iEnd = iStart + iListLength - 1;
			}

			for ( i=0, iLen=an.length ; i<iLen ; i++ ) {
				$('li:gt(0)', an[i]).filter(':not(:last)').remove();

				for ( j=iStart ; j<=iEnd ; j++ ) {
					sClass = (j==oPaging.iPage+1) ? 'class="active"' : '';
					$('<li '+sClass+'><a href="#">'+j+'</a></li>')
						.insertBefore( $('li:last', an[i])[0] )
						.bind('click', function (e) {
							e.preventDefault();
							oSettings._iDisplayStart = (parseInt($('a', this).text(),10)-1) * oPaging.iLength;
							fnDraw( oSettings );
						} );
				}

				if ( oPaging.iPage === 0 ) {
					$('li:first', an[i]).addClass('disabled');
				} else {
					$('li:first', an[i]).removeClass('disabled');
				}

				if ( oPaging.iPage === oPaging.iTotalPages-1 || oPaging.iTotalPages === 0 ) {
					$('li:last', an[i]).addClass('disabled');
				} else {
					$('li:last', an[i]).removeClass('disabled');
				}
			}
		}
	}
});

  $(function(){
    $('#carousel img').css('height', '230px').css('width', '1072px');
    
    if ( $('.carousel .item').length > 0 ) {
      $('.carousel').carousel();
    }

    $('.datatable').dataTable({
      "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span12'i><'span12 center'p>>",
      "sPaginationType": "bootstrap"
    });
    
    $(".save_selector").click(function(){
      var $widget = $( "[data-widget='" + $(this).attr("data-widget") + "']" );
      var ids = [];
      $widget.find("[data-course-id]").hide();
      $("#config_courses_holder .course_id_checkbox:checked").each(function(){
        $widget.find("[data-course-id=" + $(this).val() + "]").show();
        ids.push( $(this).val() );
      });
      if (ids.length <= 0) { 
        $widget.find(".box-body").hide(); 
      }else{
        $widget.find(".box-body").show(); 
      }
      $.ajax({
        type: "put",
        url: $(this).attr("data-url"),
        data: {"widget":{"courses": $.unique(ids).join(",") }}
      });
      $("#config_courses_holder").hide();
      return false;
    });

    $(".config_courses").click(function(){
      var $widget = $(this).parents("[data-widget]");
      var top = $widget.offset().top - 83;
      var $courses_holder = $("#config_courses_holder").css("top", top);
      var ids = [];
      $widget.find("[data-course-id]:visible").each(function(){
        ids.push( $(this).attr("data-course-id") );
      });
      $courses_holder.find(".save_selector").attr( "data-widget", $widget.attr("data-widget") ).attr( "data-url", $(this).attr("data-url") );
      $(".course_id_checkbox").each(function(){
        if ( $.inArray( $(this).val(), ids ) === -1 ) {
          $(this).removeAttr("checked");
        }else{
          $(this).attr("checked", "checked");
        }
      });
      syncCourseCheckBoxs();
      $courses_holder.hide();
      $courses_holder.show('slide', {direction: 'left'}, 500);
    });

    $("#config_courses_holder .close").click(function(){
      $("#config_courses_holder").hide('fast');
    });
    
    function syncCourseCheckBoxs(){
      $("#config_courses_holder .account_name_checkbox").each(function(){
        var $allBox = $("[data-account-name='" + $(this).val() + "']");
        var $checkedBox = $("[data-account-name='" + $(this).val() + "']:checked");
        if ( $allBox.length == $checkedBox.length ) {
          $(this).attr("checked", "checked");
        }else{
          $(this).removeAttr("checked");
        }
      });
    }

    $("#config_courses_holder .account_name_checkbox").click(function(){
      var $allBox = $("[data-account-name=" + $(this).val() + "]");
      if ( $(this).is(":checked") ) {
        $allBox.attr("checked", "checked");
      }else{
        $allBox.removeAttr("checked");
      }
    });

  });
});
