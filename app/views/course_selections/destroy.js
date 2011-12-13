Calendar.delete('.course<%= @selection.section.course.number %>');
$('#total-units').html('Total: <%= @selection.schedule.units %> units');
