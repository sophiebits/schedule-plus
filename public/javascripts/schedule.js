var Schedule = {
  init: function() {
    var start_time = 7;
    var end_time = 22
    var courses = $('#schedule .course');
    
    courses.find('.sections').hide();       /* Hide section times */
    courses.find('.options').hide();        /* Hide course options */
   
    courses.live({
      click: function() {
        /* TODO slide other courses up */
        $(this).find('.sections').slideToggle();
      },
      mouseenter: function() {
        $(this).find('.options').stop(true, true).show();
      },
      mouseleave: function() {
        $(this).find('.options').fadeOut(200);
      }
    });

    $('#calendar').append('<li><ul id="times"></ul></li>');
    for (var i = start_time; i <= end_time; ++i)
      $('#times').append('<li class="begin' + (i * 60) + '"> ' 
        + ((i - 1) % 12 + 1) + (parseInt(i / 12) ? 'pm' : 'am')
        + '<span class="half-hour"></span></li>');
    $('#times li:odd').addClass('alt');
  }
};

$(function() {
  Schedule.init();


});
