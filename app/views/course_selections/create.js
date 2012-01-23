<% if @search %> // Redirects to course search
  window.location = '<%= courses_path(:search => @search) %>';
<% elsif @selection.nil? %>
  $('#add-suggestions')
    .html('<%= escape_javascript(render(:partial => 'suggestions', :locals => {:suggestions => @results})) %>');
<% else %> // Refresh calendar with new selection
  if (suggestion_xhr) suggestion_xhr.abort();
  $('#add-suggestions').empty();
  
  var course = $('<%= escape_javascript(render(:partial => 'schedules/course', :locals => {:cs => @selection})) %>');
  course.find('.sections').hide();
  course.appendTo('#schedule');
  course.find('.course-times-link').trigger('click');
  Calendar.color(course);
  Calendar.addCourse(course);
  $('#add-course input[type=text]').val('');
  $('#total-units').html('Total: <%= @selection.schedule.units %> units');
  var days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
  for (var i = 0; i < days.length; ++i)
    Calendar.layoutDay($('#main-schedule li.' + days[i]+ ' .courses li'));
<% end %>
<% if !@no_selections %>
$('#import-scheduleman, #form-or').slideUp();
<% end %>
