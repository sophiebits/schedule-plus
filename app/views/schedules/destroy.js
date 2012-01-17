var schedule = $('#<%= @schedule.url %>');
var semester = schedule.closest('.semester');
var primary_notify = $('.no-primary-notify', semester);
<% if @none_left then %>
$('<p id="no-schedules-notify">No schedules yet for <%= @schedule.semester.name %>. <%= 
link_to "Create a new schedule", schedules_path(:semester => @schedule.semester.id), 
                    :method => :post %>.<!--or import from ScheduleMan.--></p>')
  .appendTo(semester);
<% end %>
<% if @no_primary then %>
if (primary_notify.length == 0) {
  $('<span class="no-primary-notify"><strong>You don\'t have any primary schedules for this semester</strong> (all of them are private). Your friends won\'t see which courses you\'re in!</span>').hide().insertAfter(semester.find('.semester-header')).slideDown();;
}
<% else %>
primary_notify.slideUp();
<% end %>
schedule.slideUp(300).queue(function() { $(this).remove(); });
