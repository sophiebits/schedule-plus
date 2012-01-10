
$(function() {
  $('a[tooltip]').live({
    mouseenter: function() {
      $('<span class="tooltip">'+$(this).attr('tooltip')+'</span>').appendTo(this);
    },
    mouseleave: function() {
      $(this).find('.tooltip').remove();
    }
  });
});
