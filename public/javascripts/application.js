
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

  $('#start-page .error.tooltip').hide();
  $('#start-page #add-schedule').submit(function(e) {
    e.preventDefault();
    var f = $(this);
    $('#start-page .error.tooltip').fadeOut();
    f.find('input').attr('disabled',true);
    f.find('input[type=submit]')
     .css('background-image',"url(/images/ajax-small.gif)")
    $.ajax({
      url:      f.attr('action'),
      type:     f.attr('method'),
      dataType: 'json',
      data:     'url='+f.find('input[type=text]').attr('value'),
      complete: function() {
        f.find('input').attr('disabled',false);
        f.find('input[type=submit]')
         .css('background-image',"url(/images/form-add.png)")
      },
      success: function(data,textStatus,jqXHR) {
        $.get('/main?schedule='+data.schedule.id,function(mainPage) {
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
              //addSchedule(data.schedule.scheduled_courses);
              $('.main-aside #courses-after-tooltip')
                .delay(data.schedule.scheduled_courses.length*200)
                .fadeIn(800);
              $('#fb-login')
                .delay(data.schedule.scheduled_courses.length*200)
                .fadeIn();
            });
        });
      },
      error: function(jqXHR,textStatus,errorThrown) {
        $('#start-page .error.tooltip').html(//errorThrown
          "We couldn't import your schedule. Check your URL and try again.").fadeIn();
      }
    });
  });

});


