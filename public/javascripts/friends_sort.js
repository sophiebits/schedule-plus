var name_sort = function(a, b) {
  var compA = $(a).find('.friend-name')[0].textContent;
  var compB = $(b).find('.friend-name')[0].textContent;
  return (compA < compB) ? -1 : (compA > compB) ? 1 : 0;
};

var mutual_sort = function(a, b) {
  var compA = $(a).find('.friend-mutual-courses')[0].textContent;
  var compB = $(b).find('.friend-mutual-courses')[0].textContent;
  var compA_name = $(a).find('.friend-name')[0].textContent;
  var compB_name = $(b).find('.friend-name')[0].textContent;
  compA = parseInt(compA.substr(0, compA.indexOf(" ")));
  compB = parseInt(compB.substr(0, compB.indexOf(" ")));
  return (compA > compB) ? -1 : (compA < compB) ? 1 : (compA_name > compB_name);
};

var free_sort = function(a, b) {
  var compA = $(a).find('.friend-status')[0].textContent.substr(0,1);
  var compB = $(b).find('.friend-status')[0].textContent.substr(0,1);
  var compA_name = $(a).find('.friend-name')[0].textContent;
  var compB_name = $(b).find('.friend-name')[0].textContent;
  return (compA < compB) ? -1 : (compA > compB) ? 1 : (compA_name > compB_name);
};

$(function() {
  var curr_friends = $('#curr_list').children('li');
  var curr_friends_name = curr_friends.slice();
  var curr_friends_mutual = curr_friends.slice();
  var curr_friends_free = curr_friends.slice();
  
  var old_friends = $('#old_list').children('li');
  var old_friends_name = old_friends.slice();
  
  curr_friends_name.sort(name_sort);
  curr_friends_mutual.sort(mutual_sort);
  curr_friends_free.sort(free_sort);
  old_friends_name.sort(name_sort);
  
  $('#curr_list').append(curr_friends_name);
  $('#old_list').append(old_friends_name);
  
  $('#sort-name').click(function() {
    $('#curr_list').append(curr_friends_name);
    $('#old_list').append(old_friends_name);
  });
  $('#sort-mutual').click(function() {
    $('#curr_list').append(curr_friends_mutual);
  });
  $('#sort-free').click(function() {
    $('#curr_list').append(curr_friends_free);
  });
});