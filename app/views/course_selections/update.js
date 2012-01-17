course_box = $('#course<%= @selection.course.number %>');
updated_course = "<%= escape_javascript(render :partial => 'schedules/course', :locals => {:cs => @selection} )%>";
course_box.html($(updated_course).html());
course_box.find('.friends .facebox, .friends .section-header').hide();


