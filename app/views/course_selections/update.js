$('#calendar').find('.course<%= @selection.section.course.number %>').remove();
var course = $('#schedule .course<%= @selection.section.course.number %>');
course.find('.selected_section').html('<%= @selection.section.letter %>');
course.find('.sections .selected').removeClass('selected');
course.find('.sections #section<%= @selection.section.id %>').addClass('selected');
Calendar.addCourse(course);
var days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
for (var i = 0; i < days.length; ++i)
  Calendar.layoutDay($('#main-schedule li.' + days[i] + ' .courses li'));
