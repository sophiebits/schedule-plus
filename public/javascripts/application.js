
  $(window).resize(function() {
    $('#main-bg').height($(window).height());
    $('#main-bg').css({ marginLeft:Math.max(132,($(window).width()-960)/2+132) });
    $('.page').css({ width:$(window).width() });
    $('#main-page #bg-mask').css({ width:$(window).width()/2 });
    if ($(window).width() < 1200)
      $('#acm-cmu-logo').hide();
    else
      $('#acm-cmu-logo').show();
  });

$(document).ready(function() {
 
  (new Image()).src = "/images/ajax-small.gif";

  var speed = 600;
  
  $(window).resize();
 
  $('#start-page #add-schedule').submit(function(e) {
    e.preventDefault();
    var f = $(this);
    f.find('input').attr('disabled',true);
    f.find('input[type=submit]')
     .css('background-image',"url(/images/ajax-small.gif)")
    $.ajax({
      url:      f.attr('action'),
      type:     f.attr('method'),
      dataType: 'json',
      data:     f.serialize(),
      complete: function() {
        f.find('input').attr('disabled',false);
        f.find('input[type=submit]')
         .css('background-image',"url(/images/form-add.png)")
      },
      success: function(data,textStatus,jqXHR) {
        $.get('main',function(mainPage) {
          $('#login').fadeOut();
          $(mainPage).css({
              position:'absolute',
              left:'100%',
              width:$(window).width()
            })
            .appendTo('#pages');
          $('.main-aside .tooltip').hide();
          $(window).resize();
          $('#start-page').animate({left:'-100%'},800)
            .queue(function() { $(this).remove() });
          $('#main-bg').animate({ left:'0%' },800);
          $('#main-page')
            .animate({ left:'0%' },800)
            .queue(function() {
              $(this).css('position','relative');
              addSchedule(data.user.scheduled_courses);
              $('.main-aside .tooltip')
                .delay(data.user.scheduled_courses.length*200)
                .fadeIn(800);
            });
        });
      },
      error: function(jqXHR,textStatus,errorThrown) {
        alert(errorThrown);
      }
    });
  });

});


