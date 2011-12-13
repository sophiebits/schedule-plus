var course_number = '.course<%= @selection.section.course.number %>';
$('#calendar').find(course_number).remove();
if (!$('#schedule').find(course_number).length) {
  var course = $('<%= escape_javascript(render(:partial => 'schedules/course', :locals => {:cs => @selection})) %>');
  course.appendTo('#schedule');
  course.find('.sections, .options').hide();
  course.trigger('click');
  Calendar.color(course);
}
var course = $('#schedule .course<%= @selection.section.course.number %>');
course.find('.selected_section').html('<%= @selection.section.letter %>');
course.find('.sections .selected').removeClass('selected');
course.find('.sections #section<%= @selection.section.id %>').addClass('selected');
Calendar.addCourse(course);
$('#total-units').html('Total: <%= @selection.schedule.units %> units');
var days = ['M', 'T', 'W', 'R', 'F'];
for (var i = 0; i < days.length; ++i)
  Calendar.layoutDay($('#main-schedule li.' + days[i] + ' .courses li'));
