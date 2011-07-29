$(document).ready(function() {
 
  var myCourses = [
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
      'section':'A',
      'hasRecitation':false
    },
    {
      'number':'15-221',
      'name':'Technical Communication for Computer Scientists',
      'section':'C',
      'hasRecitation':true
    },
    {
      'number':'21-301',
      'name':'Combinatorics',
      'section':'A',
      'hasRecitation':false
    },
    {
      'number':'98-163',
      'name':'StuCo: The Art of Tetris',
      'section':'A',
      'hasRecitation':false
    },
    {
      'number':'15-295',
      'name':'Special Topic: Competition Programming and Problem Solving',
      'section':'A',
      'hasRecitation':false
    }
  ];

  var colors = ["blue","steel","shamrock","yellow","orange","red"];
  var randomColors = 
    //[0,1,2,3,4,5,6];
    [5,3,1,4,2,0];

  var startTime = 7;
  var endTime = 22;
  var days = ["monday","tuesday","wednesday","thursday","friday"];

  function initCalendar() { 
    /* print times */
    $('#calendar').append('<li><ul id="times"></ul></li>');
    for (var i = startTime; i <= endTime; ++i)
      $('#times').append('<li class="begin'+(i*60)+'">'+((i-1)%12+1)
        +(parseInt(i/12) ? 'pm' : 'am')
        +'<span class="half-hour"></span></li>');
    $('#times li:odd').addClass('alt');
  }
  
  function assignColor(number, colorName) {
    
    $('.course'+number).addClass(colorName);
  }

  function addToCalendar(schedule, number, section, data, lec_rec) {
    
    $('#'+schedule+' .' + data.day + ' .courses').append(
      '<li class="course' + number + ' ' + lec_rec + ' begin' + data.begin
      + ' duration' + data.duration + '"><span class="number">' + number
      + ' ' + (lec_rec=='lecture' ? 'Lec ' : '') + section
      + '</span><span class="location">' + data.location + '</span></li>');
      
  }

  function addCourse(schedule) {

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
      
      /* add to schedule list */
      $('.schedule').append('<li class="course'+courses[i].number
        +' course"><span class="number">'+courses[i].number+' '
        +courses[i].section+'</span><span class="name">'
        +courses[i].name+'</span></li>');

      if (courses[i].selected) {
        if (courses[i].hasRecitation) {
          var rec = courses[i].recitations[courses[i].selected];
          for (var j = 0; j < rec.times.length; ++j)
            addToCalendar(scheduleId, courses[i].number, 
              rec.section, rec.times[j], 'section');
        }

        var lec = courses[i].lectures[courses[i].hasRecitation ? 
          rec.reqLecture : courses[i].selected];
        
        for (var j = 0; j < lec.times.length; ++j)
          addToCalendar(scheduleId, courses[i].number, 
            lec.section, lec.times[j], 'lecture');
      }

      assignColor(courses[i].number,colors[randomColors[i%colors.length]]);
    }

  }
  

  initCalendar();
  addSchedule(myCourses);
/*
  $('.course15-210').hover(function() {
    $('#calendar .course15-210').css({ borderColor:'#333' });
  },
  function() {
    $('#calendar .course15-210').css({ borderColor:'#ddd' }); 
  });
*/
});
