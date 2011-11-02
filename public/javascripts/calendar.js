var Calendar = {
  
  init: function() {
    var start_time = 7; /* 5AM */
    var end_time = 22;  /* 10PM */
    var courses = $('#schedule .course');
    
    courses.find('.sections').hide();       /* Hide section times */
    courses.find('.options').hide();        /* Hide course options */
   
    /*
     * Create event listeners
     */
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

    /*
     * Generate times
     */
    $('#calendar').append('<li><ul id="times"></ul></li>');
    for (var i = start_time; i <= end_time; ++i)
      $('#times').append('<li class="begin' + (i * 60) + '"> ' 
        + ((i - 1) % 12 + 1) + (parseInt(i / 12) ? 'pm' : 'am')
        + '<span class="half-hour"></span></li>');
    $('#times li:odd').addClass('alt');
  
    var days = ['M', 'T', 'W', 'R', 'F'];

    $('#calendar').append('<li id="main-schedule"><ol></ol></li>');
    for (var i = 0; i < days.length; ++i)
      $('#main-schedule ol').append('<li class="'+days[i]
        +'"><ul class="courses"></ul></li>');

    /*
     * Add courses
     */
    courses.each(function(i,c) { Calendar.addCourse(c); });
  },

  addCourse: function(course) {

    var number = $(course).find('.number').text();

    var section = $(course).find('.selected');
    var dayss = $(section).find('.days').html().split('<br>');
    var times = $(section).find('.times').html().split('<br>');
   
    for (var i = 0; i < dayss.length - 1; ++i) {
      var days = dayss[i].split("");
      for (var j = 0; j < days.length; ++j) {
//        alert($(course).find('.number').text() + days[j] + ':' + times[i]);
        $('<li class="course' + number 
          + ' begin'
          + ' duration' + '">'
          + '<span class="number">' + number + '<span>'
          + '</li>').appendTo('#calendar .' + days[j] + ' .courses');
      }
    }
  }
};

$(function() {
  Calendar.init();
});
