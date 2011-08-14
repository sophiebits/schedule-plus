
  $(window).resize(function() {
    $('#main-bg').height($(window).height());
    $('#main-bg').css({ marginLeft:Math.max(132,($(window).width()-960)/2+132) });
    $('.page').css({ width:$(window).width() });
    $('#main-page #bg-mask').css({ width:$(window).width()/2 });
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
          $('#fb-login').fadeOut();
          $(mainPage).css({
              position:'absolute',
              left:'100%',
              width:$(window).width()
            })
            .appendTo('#pages');
          $(window).resize();
          $('<div id="courses-after-tooltip" style="text-align:center"><span class="tooltip">Now that your schedule has been imported, connect to Facebook to see your friends\' schedules!</span></div>').appendTo('.main-aside').hide();
          $('#page-footer').fadeOut();
          $('#page-content').animate({height:$('#main-content').height()},800);
          $('#start-page').animate({left:'-100%'},800)
            .queue(function() { $(this).remove() });
          $('#main-bg').animate({ left:'0%' },800);
          $('#main-page')
            .animate({ left:'0%' },800)
            .queue(function() {
              $(this).css('position','relative');
              $('#page-content').height('auto');
              $('#page-footer')
                .removeClass('start')
                .show();
              addSchedule(data);
              $('.main-aside #courses-after-tooltip')
                .delay(data.length*200)
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


