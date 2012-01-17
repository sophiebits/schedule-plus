var suggestion_xhr = null;
$(function() {
  xhr = null;
  $('a[tooltip]').live({
    mouseenter: function() {
      $('<span class="tooltip">'+$(this).attr('tooltip')+'</span>').appendTo(this);
    },
    mouseleave: function() {
      $(this).find('.tooltip').remove();
    }
  });
  $('#add-course').submit(
    function() {
      if (suggestion_xhr) suggestion_xhr.abort();
      $('#add-suggestions').empty();
    }
  );
  
  function search() {
    if (suggestion_xhr) suggestion_xhr.abort();
    $('#add-suggestions').html('<li id="suggestions-notify"><a>Loading...</a></li>');
    if ($(this).val() == '')
      $('#add-suggestions').empty();
    else{
      var form = $('#add-course');
      suggestion_xhr = $.ajax({
        url: form.attr('action'),
        type: 'POST',
        cache: true,
        data: { semester: form.find('input[name="semester"]').val(), search: $(this).val() },
        dataType: 'script',
        success: function(data, textStatus, jqXHR) {
        }
      });
    }
  }

  //Added a timeout of 500ms to not overload server with requests on every keypress
  $('#add-course #search').live({
      keyup: function(e) {
        clearTimeout($.data(this, 'timer'));
        if (e.keyCode != 13) {
          $(this).data('timer', setTimeout($.proxy(search, this), 500));
        }
      }
  });
});
