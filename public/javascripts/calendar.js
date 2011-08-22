 

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

    var begin = data.begin;
    var end = parseInt(data.end)+10;

    data.day = data.day.toLowerCase();

    $('<li class="course' + number + ' ' + lec_rec + ' begin' + begin
      + ' duration' + (end - begin) + '" course-number="' 
      + number + '"><span class="number">' + number
      + ' ' + (lec_rec=='lecture' ? 'Lec ' : '') + section
      + '</span><span class="location">' + data.location + '</span></li>')
     .appendTo('#'+schedule+' .' + data.day + ' .courses').hide().delay(delay);
   
    
    var conflicts = $('#'+schedule+' .' + data.day + ' .courses .begin' + begin);
      for (var i = 0; i < conflicts.length; ++i)
        conflicts.eq(i).show().css({ opacity:0 })
          .animate({ 
            width: (105/conflicts.length),//-5,
            left:i*105/conflicts.length,
            opacity:1
          },200);
  }

  function addCourse(scheduleId,data,i) {
      
      var course = data.course;
      var lecture = data.lecture;
      var recitation = data.recitation;
      course.has_recitation = recitation != null;
      /* add to schedule list */
      $('.schedule').append('<li class="course' + course.number
        + ' course" course-number="' + course.number 
        + '" course-id="' + course.id 
        + '" sched-id="' + data.id
        + '"><span class="number">' + course.number + ' '
        + (course.has_recitation ? recitation.section : lecture.section)
        + '</span><span class="name">'
        + course.name + '</span><div class="friends" style="display:none"></div></li>');
      $('.schedule .course' + course.number)
        .css({ height:$('.schedule .course' + course.number).height() })
        .hide()
        .delay(i*200)
        .slideDown()
        .height('auto');
      if (course.has_recitation) {
        recitation.times = recitation.recitation_section_times;
        for (var j = 0; j < recitation.times.length; ++j)
          if (recitation.times[j].begin != -1)
            addToCalendar(scheduleId, course.number, 
              recitation.section, recitation.times[j], 'section', i*200);
      }
      lecture.times = lecture.lecture_section_times
      for (var j = 0; j < lecture.times.length; ++j)
        if (lecture.times[j].begin != -1)
          addToCalendar(scheduleId, course.number, 
            lecture.section, lecture.times[j], 
            course.has_recitation ? 'lecture' : 'section', i*200);
      
      assignColor(course.number,colors[randomColors[i%colors.length]]);
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
      addCourse(scheduleId,courses[i],i);
    }
  }

//
// Event listener to add highlight class to course
//////////////////////////////////////////////////////////
$('#main-content').delegate('.course, .section, .lecture','hover',function(e) {
  if (e.type === 'mouseenter')
    $('.course' + $(this).attr('course-number')).addClass('highlight');
  else
    $('.course' + $(this).attr('course-number')).removeClass('highlight');
});
//
// Event listener to load friends in a course
/////////////////////////////////////////////////////////
// $('#main-content').delegate('.course, .section, .lecture','click',loadFriends);

function loadFriends() {
      
  var number = $(this).attr('course-number');
  var course_id = $('.schedule .course'+number).attr('course-id');
  var sched_id = $('.schedule .course'+number).attr('sched-id');

  $('.schedule .friends').stop(true,true).slideUp(); 
      
  if ($('.course' + number).hasClass('selected')) {
    $('.course, .lecture, .section').removeClass('selected')
  } else {
    $('.course, .lecture, .section').removeClass('selected');
    $('.course' + number).addClass('selected');
    $('.schedule .course' + number + ' .friends')
      .slideDown();
   
    if (!$('.schedule .course' + number + ' .friends').hasClass('loaded'))
      
      $('.schedule .course' + number + ' .friends')
        .append('<img class="loading" src="/images/ajax-friends.gif" />')
      
      $.ajax({
        url:      '/schedules/get_friends_in_course',
        type:     'GET',
        dataType: 'json',
        data:     'scheduled_course_id='+sched_id,
        complete: function() {},
        success: function(resp,textStatus,jqXHR) {
          html = '<ul>';
          if (resp.me)
            html += '<li class="me"><a href="/schedules"><img src="http://graph.facebook.com/'
                  + resp.me + '/picture" /></a></li>';
          for (var j = 0; j < resp.data.length; ++j) {
            var friend = resp.data[j].user
            html += '<li><a href="/friends/' + friend.id + '">'
                  + '<img src="http://graph.facebook.com/' + friend.uid 
                  + '/picture" /></a></li>';
          }
          html += '</ul>';
          $('.schedule .course'+ number + ' .friends')
            .html(html).addClass('loaded');
        },
        error: function(jqXHR,textStatus,errorThrown) {
          alert('error: '+errorThrown);
       }
     }); 
  }
}

$(document).ready(function() {

  initCalendar();
  //addSchedule(schedules[0]);
  
  $('#add-course').live('submit',function(e) {
    e.preventDefault();
    var f = $(this);
    f.find('input').attr('disabled',true);
    f.find('input[type=submit]')
     .css('background-image',"url(/images/ajax-small.gif)")
    $.ajax({
      url:  f.attr('action'),
      type: f.attr('method'),
      dataType: 'json',
      data: 'course='+f.find('input[type=text]').attr('value'),
      complete: function() {
        f.find('input').attr('disabled',false);
        f.find('input[type=submit]')
         .css('background-image',"url(/images/form-add.png)") 
      },
      success: function(data,textStatus,jqXHR) {
        //alert(JSON.stringify(data));
        addCourse('my-schedule',data.scheduled_course,$('.schedule .course').length);
      },
      error: function(jqXHR, textStatus, errorThrown) {
        alert('error: '+errorThrown);
      }
    });
  });

});
