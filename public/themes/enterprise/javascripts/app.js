require([
  "jquery",
  "/themes/enterprise/javascripts/jquery.jcarousel.js",
  "/themes/enterprise/javascripts/jquery.vticker-min.js",
  "/themes/enterprise/javascripts/jquery.dataTables.js",
  "/javascripts/vendor/jqueryui/effects/slide.js"], function($){
  
  $(document).ready(function(){
  
    // Init data table
    $(".datatable").dataTable({
      "sDom": 'ft',
      "aaSorting": [[ 2, "desc" ]],
      "aoColumns": [ null, null, null, null, null ]
    });

    // vertical tickers
    // http://www.htmldrive.net/items/show/266/jquery-vticker-vertical-news-ticker
    $(".account_announcement_holder").vTicker({
      mousePause: true,
      speed: 500,
		  pause: 3000,
		  animation: 'fade',
		  showItems: 11
    });

    function mycarousel_initCallback(carousel)
    {
      // Disable autoscrolling if the user clicks the prev or next button.
      carousel.buttonNext.bind('click', function() {
          carousel.startAuto(0);
      });

      carousel.buttonPrev.bind('click', function() {
          carousel.startAuto(0);
      });

      // Pause autoscrolling if the user moves with the cursor over the clip.
      carousel.clip.hover(function() {
          carousel.stopAuto();
      }, function() {
          carousel.startAuto();
      });
      
      var list = carousel.list.find(".jcarousel-item").show();
      list.find("img").css( "width", list.width() );
    };

    $('#mycarousel').jcarousel({
        auto: 2,
        wrap: 'last',
        scroll: 1,
        visible: 2,
        initCallback: mycarousel_initCallback
    });

    $(".save_selector").click(function(){
      var $widget = $( "[data-widget='" + $(this).attr("data-widget") + "']" );
      var ids = [];
      //$widget.find("[data-course-id]").hide();
      $("#config_courses_holder .course_id_checkbox:checked").each(function(){
        $widget.find("[data-course-id=" + $(this).val() + "]").show();
        ids.push( $(this).val() );
      });
      //if (ids.length <= 0) { 
        //$widget.find(".box-body").hide(); 
      //}else{
        //$widget.find(".box-body").show(); 
      //}
      $.ajax({
        type: "put",
        url: $(this).attr("data-url"),
        data: {"widget":{"courses": $.unique(ids).join(",") }}
      });
      $("#config_courses_holder").hide();
      window.location.reload();
      return false;
    });

    $(".config_courses").click(function(){
      var $widget = $(this).parents("[data-widget]");
      var top = $widget.offset().top - 143;
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
