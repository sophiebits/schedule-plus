
  $(document).ready(function() {
    
    if ($(this).val().length > 0) {
      $('#search-friends-cancel').show();
    } else {
      $('#search-friends-cancel').hide();
    }
    
    $('#sort-name').addClass('active');
   
    var activeSortIndex = 0;
    
    var sortedFriends = [];
    //sortedFriends[0] = #@friends.order('users.name').map{|f| cic = f.courses_in_common(current_user); {'id'=>f.id, 'name'=>f.name, 'uid'=>f.uid, 'status'=>f.status, 'cic'=>cic, 'cic_count'=>cic.count}}.to_json.html_safe %>;

    sortedFriends[1] = sortedFriends[0].slice(0).sort(function(a, b) {
      var aStatus = a.status == 'free';
      var bStatus = b.status == 'free';
      if (aStatus == bStatus) {
        return a.name > b.name ? 1 : -1;
      } else {
        return aStatus < bStatus ? 1 : -1;
      }
    });
    
    sortedFriends[2] = sortedFriends[0].slice(0).sort(function(a, b) {
      var aCicCount = a.cic_count;
      var bCicCount = b.cic_count;
      if (aCicCount == bCicCount) {
        return a.name > b.name ? 1 : -1;
      } else {
        return aCicCount < bCicCount ? 1 : -1;
      }
    });

    var friendsHtml = $('#friends-container .friend');
    
    function makeActiveSortButton(sortButton) {
      $.each($('#sort-friends span'), function() {
        $(this).removeClass('active');
      });
      sortButton.addClass('active');
    }

    function refreshPages(friends) {
      html = '<li class="friends-page"><ul>';
      for(var i = 0; i < friends.length; ++i) {
        // start of a new friends page
        if(i && !(i % 10)) {
          html += '</ul></li><li class="friends-page"><ul>';
        }
        
        var f = friends[i];
        html += '<li class="friend"><a href="/friends/'+f.id+'"><img src="http://graph.facebook.com/'+f.uid+'/picture" /><span class="name">'+f.name+'</span><span class="status">'+f.status+'</span>';
        html += '<span class="common-courses">';
        // tooltip if courses in common count is positive
        if (f.cic_count > 0) {
          html += '<span class="tooltip"><ul>';
          $.each(f.cic, function(index, course) {
            html += '<li>'+course.number+': '+course.name+'</li>';
          });
          html += '</ul></span>';
        }
        
        html += '<span class="count">'+f.cic_count+' courses in common</span></span>';   
      }
      html += '</a></li></ul></li>';
      // alert(html);
      // console.log('a');
      $('#friends-container').html(html);
      $('.common-courses .tooltip').hide();
      $('.common-courses .tooltip > ul > li').textOverflow();
      initSlider('#friends','#friends-container','.friends-page',0);
    }

    // default is to show friends sorted by name
    refreshPages(sortedFriends[activeSortIndex]);

    $('#search-friends').submit(function(e) {
      e.preventDefault();
    });

    function updateResults() {
      var input = $('#search-input').val().toLowerCase();
      var results = [];
      var regex = new RegExp(input,"gi");
      

      for(var i = 0; i < sortedFriends[activeSortIndex].length; ++i) {
        if(sortedFriends[activeSortIndex][i].name.search(regex) != -1) {
          results.push(sortedFriends[activeSortIndex][i]);
        }
      }

      refreshPages(results);
    }
    
    $('#search-input').keyup(function() {
      if ($(this).val().length > 0) {
        $('#search-friends-cancel').show();
      } else {
        $('#search-friends-cancel').hide();
      }
      updateResults();
    });

    $('#search-friends-cancel').click(function() {
      $('#search-input').val('');
      $('#search-friends-cancel').hide();
      updateResults();
    });

    $('#sort-name').click(function() {
      makeActiveSortButton($(this));
      activeSortIndex = 0;
      updateResults();
    });
    $('#sort-free').click(function() {
      makeActiveSortButton($(this));
      activeSortIndex = 1;
      updateResults();
    });
    $('#sort-cic').click(function() {
      makeActiveSortButton($(this));
      activeSortIndex = 2;
      updateResults();
    });
    
    
  });
