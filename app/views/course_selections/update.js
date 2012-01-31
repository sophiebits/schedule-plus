$('#calendar').find('.course<%= @selection.section.course.number %>').remove();
var course = $('#schedule .course<%= @selection.section.course.number %>');
course.find('.selected_section').html('<%= @selection.section.letter %>');
course.find('.sections .selected').removeClass('selected');
course.find('.sections #section<%= @selection.section.id %>').addClass('selected');
Calendar.addCourse(course);
var days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
for (var i = 0; i < days.length; ++i)
  Calendar.layoutDay($('#main-schedule li.' + days[i] + ' .courses li'));
  
course_box = $('#course<%= @selection.course.number %>');
updated_course = "<%= escape_javascript(render :partial => 'schedules/course', :locals => {:cs => @selection} )%>";
course_box.html($(updated_course).html());
course_box.find('.friends .facebox, .friends .section-header').hide();
