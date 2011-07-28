$(document).ready(function() {
  
  function initCalendar() {
  
    var startTime = 7;
    var endTime = 22;
  
    /* print times */
    $('#calendar').append('<li><ul id="times"></ul></li>');
    for (var i = startTime; i <= endTime; ++i)
      $('#times').append('<li class="s'+i+'00">'+((i-1)%12+1)+
        (parseInt(i/12) ? 'pm' : 'am')
        +'<span class="half-hour"></span></li>');
  
    $('#times li:odd').addClass('alt');
  }
  
  initCalendar();
  
});
