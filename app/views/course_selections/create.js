var course = $('<%= escape_javascript(render(:partial => 'schedules/course', :locals => {:cs => @selection})) %>');
course.appendTo('#schedule');
course.find('.sections, .options').hide();
course.trigger('click');
Calendar.color(course);
Calendar.addCourse(course);
$('#add-course input').val('');
$('#total-units').html('Total: <%= @selection.schedule.units %> units');
var days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
for (var i = 0; i < days.length; ++i)
  Calendar.layoutDay($('#main-schedule li.' + days[i] + ' .courses li'));
