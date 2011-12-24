$('.schedule').each(function() {
  $(this).find('.pub-link').remove();
  if ($('#page-content').hasClass('schedule'))
    $('<a href="#" class="schedule-public pub-link">public</a>')
      .appendTo($(this).find('#schedule-options'));
  else {  
    if ($(this).attr('id') == '<%= @schedule.url %>')
      $('<a href="#" class="schedule-public pub-link">public</a>')
        .appendTo($(this).find('.schedule-options'));
    else
      $('<a href="/schedules/' + $(this).attr('id') + '?schedule[active]=true"' +
        ' class="schedule-private pub-link"' +
        ' data-method="put" data-remote="true" rel="nofollow">private</a>')
        .appendTo($(this).find('.schedule-options'));
   }
});
