$(document).ready(function() {
 
  (new Image()).src = "/images/form-add.png";

  var speed = 600;
  
  $(window).resize(function() {
    $('.page').css({ width:$(window).width() });
    $('#main-page').css({ height:$(window).height() });
    $('#main-page #bg-mask').css({ width:$(window).width() });
    $('#page-content').css({ height:$(window).height() });
    if ($(window).width() < 1200)
      $('#acm-cmu-logo').hide();
    else
      $('#acm-cmu-logo').show();
  });
  $(window).resize();

  
  $('#add-schedule input[type=submit]').click(function() {
    $(this).css('background-image',"url(/images/ajax-small.gif)")
  });

});


