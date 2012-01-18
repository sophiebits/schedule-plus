$(function() {
  $('.expand').toggle(
    function() {
      var facebox = $(this).parent();
      var count = 0;
      var num_friends = facebox.find('li').length;
      facebox.find('li.friends-expand').each(function() {
        count++;
        $(this).show();
      });
      $(this).html('hide');
      // FIXME this is pretty hacked, need better way to "auto" resize the box
      facebox.animate({"height": (53 * Math.ceil(num_friends / 10) - 2)});
    },
    function() {
      var facebox = $(this).parent();

      facebox.animate({"height": "50px"}, function() {
        facebox.find('li.friends-expand').each(function(e) {
          $(this).hide();
        });
      });
      $(this).html('see all');

    }
  );
});
