 

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

      course.has_recitation = recitation != null;

      /* add to schedule list */
      $('.schedule').append('<li class="course' + course.number
        + ' course" course-number="' + course.number 
        + '" course-id="' + course.id 
        + '" sched-id="' + courses[i].id
        + '"><span class="number">' + course.number + ' '
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
        var number = $(this).attr('course-number');
        var course_id = $(this).attr('course-id');
        var sched_id = $(this).attr('sched-id');

          $('.schedule .friends').stop(true,true).slideUp(); 
        
        if ($('.course' + number).hasClass('selected')) {
          $('.course, .lecture, .section').removeClass('selected')
        } else {
          $('.course, .lecture, .section').removeClass('selected');
          $('.course' + number).addClass('selected');
          $('.schedule .course' + number + ' .friends')
            .slideDown();
         
          $.ajax({
            url:      '/schedules/get_friends_in_course',
            type:     'GET',
            dataType: 'json',
            data:     'scheduled_course_id='+sched_id,
            complete: function() {},
            success: function(data,textStatus,jqXHR) {
              html = '<ul><li class="me"><img src="http://graph.facebook.com/vincentsiao/picture" /></li>';
              for (var j = 0; j < data.length; ++j)
                html += '<li><img src="http://graph.facebook.com/'+data[j].user.uid+'/picture" /></li>';
              html += '</ul>';
              $('.schedule .course'+ number + ' .friends')
                .html(html);
            },
            error: function(jqXHR,textStatus,errorThrown) {
              alert(errorThrown);
            }
          });
        
        }
      });
    }

  }
  
$(document).ready(function() {

  initCalendar();
  //addSchedule(schedules[0]);

});
