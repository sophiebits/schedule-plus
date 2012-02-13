var form = $('#name-<%= @schedule.url %>');
if (form.attr('class') == 'schedule-title-name') {
  form.html('<input type="hidden" name="schedule_id" value="<%= @schedule.id %>" /><input type="text" name="new_name" size="15" value="<%= @schedule.name %>"/> <input type="submit" value="done" />');
  form.attr('class', 'schedule-title-rename');
  form.children('input:text').select();
} else {
  form.html('<input type="hidden" name="schedule_id" value="<%= @schedule.id %>" /><span><%= @schedule.name %></span> <input type="submit" value="rename" />');
  form.attr('class', 'schedule-title-name');
}