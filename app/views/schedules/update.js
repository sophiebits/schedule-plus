if ($('#page-content').hasClass('schedules')) {
	// in "Browse Schedules" view
	$('.semester-schedules').each(function() {
		// find the semester group for @schedule
		if ($(this).children('li[id="<%= @schedule.url %>"]').length != 0) {
			$(this).children().each(function() {
				$(this).find('.schedule-primary').remove();
				if ($(this).attr('id') == '<%= @schedule.url %>')
      		$('<a href="#" class="schedule-primary selected">public</a>')
        	  .appendTo($(this).find('.schedule-options'));
    		else
      		$('<a href="/schedules/' + $(this).attr('id') + '?schedule[primary]=true"' +
       		  ' class="schedule-primary toggable"' +
       		  ' data-method="put" data-remote="true" rel="nofollow">private</a>')
       		  .appendTo($(this).find('.schedule-options'));
			});
		}
	});
} else if ($('#page-content').hasClass('schedule')) {
	// in main schedule calendar view
	$('<a href="#" class="schedule-primary">public</a>')
	  .appendTo($(this).find('#schedule-options'));
}
