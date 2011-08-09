
  $(window).resize(function() {
    $('#main-bg').height($(window).height());
    $('#main-bg').css({ marginLeft:Math.max(132,($(window).width()-960)/2+132) });3
    $('.page').css({ width:$(window).width() });
    $('#main-page #bg-mask').css({ width:$(window).width()/2 });
    if ($(window).width() < 1200)
      $('#acm-cmu-logo').hide();
    else
      $('#acm-cmu-logo').show();
  });

$(document).ready(function() {
 
  (new Image()).src = "/images/form-add.png";

  var speed = 600;
  
  $(window).resize();

  
  $('#add-schedule input[type=submit]').click(function() {
    $(this).css('background-image',"url(/images/ajax-small.gif)")
  });

});


