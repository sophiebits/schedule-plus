 
  var schedules = [[
    {
      'number':'15-210',
      'name':'Parallel and Sequential Data Structures and Algorithms',
      'hasRecitation':true,
      'selected':3,
      'lectures': [
        {
          'section':'1',
          'times':[
            { 'day':'tuesday', 'begin':'630', 
              'duration':'90', 'location':'BH 136A' },
            { 'day':'thursday', 'begin':'630', 
              'duration':'90', 'location':'BH 136A' }
          ]
        },{}
      ],
      'recitations': [
        {},{},{},
        {
          'section':'D', 'reqLecture':0,
          'times':[
            { 'day':'wednesday', 'begin':'810',
              'duration':'60', 'location':'DH 1211' }
          ]
        }
      ]
    },
    {
      'number':'15-213',
      'name':'Introduction to Computer Systems',
      'hasRecitation':true,
      'selected':5,
      'lectures': [
        {
          'section':'1',
          'times':[
            { 'day':'tuesday', 'begin':'810', 
              'duration':'90', 'location':'DH 2315' },
            { 'day':'thursday', 'begin':'810', 
              'duration':'90', 'location':'DH 2315' }
          ]
        }
      ],
      'recitations': [
        {},{},{},{},{},
        {
          'section':'F', 'reqLecture':0,
          'times':[
            { 'day':'monday', 'begin':'810',
              'duration':'60', 'location':'DH 1211' }
          ]
        }
      ]
    },
    {
      'number':'15-396',
      'name':'Special Topic: Science of the Web',
      'hasRecitation':false,
      'selected':0,
      'lectures': [
        { 
          'section':'A',
          'times':[
            { 'day':'tuesday', 'begin':'900',
              'duration':'90', 'location':'HBH 1000' },
            { 'day':'thursday', 'begin':'900',
              'duration':'90', 'location':'HBH 1000' }
          ]
        }
      ]
    },
    {
      'number':'15-221',
      'name':'Technical Communication for Computer Scientists',
      'hasRecitation':true,
      'selected':2,
      'lectures': [
        {
          'section':'1',
          'times':[
            { 'day':'tuesday', 'begin':'540',
              'duration':'90', 'location':'BH A51' },
            { 'day':'thursday', 'begin':'540',
              'duration':'90', 'location':'BH A51' }
          ]
        }
      ],
      'recitations': [
        {},{},
        {
          'section':'C', 'reqLecture':0,
          'times':[
            { 'day':'friday', 'begin':'690',
              'duration':'60', 'location':'GHC 4211' }
          ]
        }
      ]
    },
    {
      'number':'21-301',
      'name':'Combinatorics',
      'hasRecitation':false,
      'selected':0,
      'lectures': [
        {
          'section':'A',
          'times': [
            { 'day':'monday', 'begin':'750',
              'duration':'60', 'location':'BH A51' },
            { 'day':'wednesday', 'begin':'750',
              'duration':'60', 'location':'BH A51' },
            { 'day':'friday', 'begin':'750',
              'duration':'60', 'location':'BH A51' }
          ]
        },{}
      ]
    },
    {
      'number':'98-163',
      'name':'StuCo: The Art of Tetris',
      'hasRecitation':false,
      'selected':0,
      'lectures': [
        {
          'section':'A',
          'times': [
            { 'day':'tuesday', 'begin':'1110',
              'duration':'60', 'location':'WEH 5415' }
          ]
        }
      ]
    },
    {
      'number':'15-295',
      'name':'Special Topic: Competition Programming and Problem Solving',
      'hasRecitation':false,
      'selected':0,
      'lectures': [
        {
          'section':'A',
          'times': [
            { 'day':'wednesday', 'begin':'1110',
              'duration':'180', 'location':'WEH 5421' }
          ]
        }
      ] 
    }
  ]];

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

    $('#'+schedule+' .' + data.day + ' .courses').append(
      '<li class="course' + number + ' ' + lec_rec + ' begin' + data.begin
      + ' duration' + (data.end - data.begin) + '" title="' + number + '"><span class="number">' + number
      + ' ' + (lec_rec=='lecture' ? 'Lec ' : '') + section
      + '</span><span class="location">' + data.location + '</span></li>');
    
    var conflicts = $('#'+schedule+' .' + data.day + ' .courses .begin' + data.begin);
    conflicts.stop(true,true).hide();
    if (conflicts.length > 1) {
      conflicts.css('width', (105/conflicts.length)-5+'px');
      for (var i = 1; i < conflicts.length; ++i)
        conflicts.eq(i).css({ left:i*105/conflicts.length+'px' });
    }
    conflicts.delay(delay).fadeIn(800);
  
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

      /* add to schedule list */
      $('.schedule').append('<li class="course' + course.number
        + ' course" title="' + course.number + '"><span class="number">'
        + course.number + ' '
        + (course.has_recitation ? recitation.section : lecture.section)
        + '</span><span class="name">'
        + course.name + '</span></li>');
      
      $('.schedule .course' + course.number)
        .css({ height:$('.schedule .course' + course.number).height() })
        .hide()
        .delay(i*400)
        .slideDown(400);

        if (course.has_recitation) {
          recitation.times = recitation.recitation_section_times;
          for (var j = 0; j < recitation.times.length; ++j)
            addToCalendar(scheduleId, course.number, 
              recitation.section, recitation.times[j], 'section',
              i*400);
        }

        lecture.times = lecture.lecture_section_times
        for (var j = 0; j < lecture.times.length; ++j)
          addToCalendar(scheduleId, course.number, 
            lecture.section, lecture.times[j], 
            course.has_recitation ? 'lecture' : 'section',
            i*400);

      assignColor(course.number,colors[randomColors[i%colors.length]]);

      $('.course' + course.number).hover(function() {
        $('.course' + $(this).attr('title')).addClass('highlight');
      },function() {
        $('.course' + $(this).attr('title')).removeClass('highlight');
      });
    }

  }
  
$(document).ready(function() {

  initCalendar();
  //addSchedule(schedules[0]);

});
