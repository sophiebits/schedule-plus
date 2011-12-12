$('#calendar').find('.course<%= @selection.section.course.number %>').remove();
if (!$('#schedule').find('.course<%= @selection.section.course.number %>').length) {
$('<li class="course<%= @selection.section.course.number %> course">' +
          '<span class="number"><%= @selection.section.course.number %></span><span class="selected_section"><%= @selection.selected_section %></span>' +
          '<span class="name"><%= @selection.name %></span>' +
          '<div class="options" style="display:none">' +
            '<%= link_to "info", course_path(@selection.course), :class => "course-info-link" %>' +
            '<%= link_to "times", course_path(@selection.course), :class =>"course-times-link" %>' +
            '<%= link_to "delete", schedule_selection_path(:schedule_id => @selection.schedule, :id => @selection.id),
                             :method => :delete,
                             :remote => true,
                             :class => "course-delete-link" %>' +
          '</div>'+
          '<ul class="sections">'+
      <% @selection.course.sections_by_lecture.each do |lecture, sections| %>
        <% if lecture %>
              '<li class="lecture">'+
                '<!-- class="add-course">&nbsp;</-->'+
                '<span class="lecture-num">Lec<%= lecture.number %></span>'+
                '<span class="days">'+<% lecture.scheduled_times.each do |time| %>
                  '<%= time.days %><br />'+
                <% end %>'</span>'+
                '<span class="times">'+<% lecture.scheduled_times.each do |time| %>
                  '<%= time.to_str %><br />'+
                <% end %>'</span>'+
                '<span class="locations">'+<% lecture.scheduled_times.each do |time| %>
                  '<%= time.location %><br />'+
                <% end %>'</span>'+
              '</li>'+
        <% end %>
        <% sections.each do |section| %>
          '<li class="section <%= cycle('odd', 'even', :name => 'parity') %><%= " selected" if @selection.section == section %>" id="section<%= section.id %>">'+
            '<a href="<%= schedule_selections_path(:schedule_id => @selection.schedule, :id => section.id)%>" data-method="post" data-remote="true">'+
            '<span class="section-ltr"><%= section.letter %></span>'+
            '<span class="days"><% section.scheduled_times.each do |time| %><%= time.days %><br /><% end %></span>'+
            '<span class="times"><% section.scheduled_times.each do |time| %><%= time.to_str %><br /><% end %></span>'+
            '<span class="locations"><% section.scheduled_times.each do |time| %><%= time.location %><br /><% end %></span>'+
            '</a>'+
          '</li>'+
        <% end %>
        <% reset_cycle('parity') %>
      <% end %>
          '</ul>'+
        '</li>').appendTo('#schedule').find('.sections, .options').hide();
$('.course<%= @selection.section.course.number %>').trigger('click');
}
var course = $('#schedule .course<%= @selection.section.course.number %>');
course.find('.selected_section').html('<%= @selection.section.letter %>');
course.find('.sections .selected').removeClass('selected');
course.find('.sections #section<%= @selection.section.id %>').addClass('selected');
Calendar.addCourse(course);
//$('.course<%= @selection.section.course.number %>').addClass('highlight');
var days = ['M', 'T', 'W', 'R', 'F'];
for (var i = 0; i < days.length; ++i) {
  Calendar.layoutDay($('#main-schedule li.' + days[i] + ' .courses li'));
}
