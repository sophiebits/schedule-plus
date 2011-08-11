 

  var colors = ["blue","steel","shamrock","yellow",
                "orange","red","magenta","purple"];
  var randomColors = 
    //[0,1,2,3,4,5,6];
    [5,3,1,2,7,4,6,0];

  var startTime = 7;
  var endTime = 22;
  var days = ["monday","tuesday","wednesday","thursday","friday"];

  /* generates calendar time dividers */
  function initCalendar() { 
    $('#calendar').append('<li><ul id="times"></ul></li>');
    for (var i = startTime; i <= endTime; ++i)
      $('#times').append('<li class="begin'+(i*60)+'">'+((i-1)%12+1)
        +(parseInt(i/12) ? 'pm' : 'am')
        +'<span class="half-hour"></span></li>');
    $('#times li:odd').addClass('alt');
  }
  
  /* assigns display color to a course by adding color class to elements */
  function assignColor(number, colorName) {
    
    $('.course'+number+', .course'+number+' .color').addClass(colorName);
  }

  /* adds a course to calendar and adjusts conflicting courses with the same begin time */
  function addToCalendar(schedule, number, section, data, lec_rec, delay) {

    //var begin = parseInt(data.begin/100)*60+parseInt(data.begin%100);
    //var end = parseInt(data.end/100)*60+parseInt(data.end%100)+10;

    var begin = data.begin;
    var end = parseInt(data.end)+10;

    data.day = data.day.toLowerCase();

    $('<li class="course' + number + ' ' + lec_rec + ' begin' + begin
      + ' duration' + (end - begin) + '" title="' 
      + number + '"><span class="number">' + number
      + ' ' + (lec_rec=='lecture' ? 'Lec ' : '') + section
      + '</span><span class="location">' + data.location + '</span></li>')
     .appendTo('#'+schedule+' .' + data.day + ' .courses').hide().delay(delay);
   
    
    var conflicts = $('#'+schedule+' .' + data.day + ' .courses .begin' + begin);
      for (var i = 0; i < conflicts.length; ++i)
        conflicts.eq(i).show().css({ opacity:0 })
          .animate({ 
            width: (105/conflicts.length)-5+'px',
            left:i*105/conflicts.length+'px',
            opacity:1
          },200);
  }

  function addCourse(schedule, course) {
    alert(course);
  }

  function addSchedule(courses, name) {
    /* create schedule */
    if (!name) name = "my";
    scheduleId = name+'-schedule';
    $('#calendar').append('<li id="'+scheduleId+'"><ol></ol></li>');
    
    /* create day containers */
    for (var i = 0; i < days.length; ++i)
      $('#'+scheduleId+' ol').append('<li class="'+days[i]
        +'"><ul class="courses"></ul></li>');
    
    for (var i = 0; i < courses.length; ++i) {
      
      var course = courses[i].course;
      var lecture = courses[i].lecture;
      var recitation = courses[i].recitation;

      course.has_recitation = true;

      /* add to schedule list */
      $('.schedule').append('<li class="course' + course.number
        + ' course" title="' + course.number + '"><span class="number">'
        + course.number + ' '
        + (course.has_recitation ? recitation.section : lecture.section)
        + '</span><span class="name">'
        + course.name + '</span><div class="friends" style="display:none"><img class="loading" src="/images/ajax-friends.gif" /></div></li>');
      
      $('.schedule .course' + course.number)
        .css({ height:$('.schedule .course' + course.number).height() })
        .hide()
        .delay(i*200)
        .slideDown()
        .height('auto');
        
        if (course.has_recitation) {
          recitation.times = recitation.recitation_section_times;
          for (var j = 0; j < recitation.times.length; ++j)
            addToCalendar(scheduleId, course.number, 
              recitation.section, recitation.times[j], 'section',
              i*200);
        }

        lecture.times = lecture.lecture_section_times
        for (var j = 0; j < lecture.times.length; ++j)
          addToCalendar(scheduleId, course.number, 
            lecture.section, lecture.times[j], 
            course.has_recitation ? 'lecture' : 'section',
            i*200);

      assignColor(course.number,colors[randomColors[i%colors.length]]);

      $('.course' + course.number).hover(function() {
        $('.course' + $(this).attr('title')).addClass('highlight');
      },function() {
        $('.course' + $(this).attr('title')).removeClass('highlight');
      });
      $('.course' + course.number).click(function() {
        var number = $(this).attr('title');
        
          $('.schedule .friends').stop(true,true).slideUp(); 
        
        if ($('.course' + number).hasClass('selected')) {
          $('.course, .lecture, .section').removeClass('selected')
        } else {
          $('.course, .lecture, .section').removeClass('selected')
          $('.course' + number).addClass('selected')
          $('.schedule .course' + number + ' .friends')
            .slideDown()
            .delay(1000)
            .queue(function() {
              $('.schedule .course' + number + ' .friends')
              .html('<ul><li class="me"><img src="http://graph.facebook.com/vincentsiao/picture" /></li><li><img src="http://graph.facebook.com/adam.weis1/picture" /></li><li><img src="http://graph.facebook.com/jason.macdonald1/picture" /></li><li><img src="http://graph.facebook.com/ericwu56/picture" /></li><li><img /></li><li><img /></li><li><img /></li><li><img /></li><li><img /></li><li><img /></li></ul>')
              
            });
         /* 
          $.ajax({
            url:
            type:
            dataType: 'json',
            data:     'number='+number,
            complete: function() {

            },
          });
        */
        }
      });
    }

  }
  
$(document).ready(function() {

  initCalendar();
  //addSchedule(schedules[0]);

});
