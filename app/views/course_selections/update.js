$('#calendar').find('.course<%= @selection.section.course.number %>').remove();
var course = $('#schedule .course<%= @selection.section.course.number %>');
course.find('.selected_section').html('<%= @selection.section.letter %>');
course.find('.sections .selected').removeClass('section');

