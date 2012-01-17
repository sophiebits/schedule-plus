var schedule = $('#<%= @schedule.url %>');
<% if @none_left then %>
var semester = schedule.closest('.semester');
$('.no-primary-notify', semester).slideUp();
$('<p id="no-schedules-notify">No schedules yet for <%= @schedule.semester.name %>. <%= 
link_to "Create a new schedule", schedules_path(:semester => @schedule.semester.id), 
                    :method => :post %>.<!--or import from ScheduleMan.--></p>')
  .appendTo(semester);
<% end %>
schedule.slideUp(300).queue(function() { $(this).remove(); });
