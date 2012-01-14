$(function(){
$('.fb-share').click(function(e) {
      e.preventDefault();
      FB.ui({ method:'feed',
        name:'schedule+',
        link:'http://scheduleplus.org/',
        picture:'http://scheduleplus.org/images/schedule-plus-logo-square.jpg',        description:'schedule+ connects you to your Carnegie Mellon friends on  Facebook by matching your planned course schedules. See which courses are most  common among your friends, or find out which of your friends is free for a      lunchtime get-together.',        message:"I'm now using schedule+ to share my CMU schedule with friends. Check it out!"      });
      return false;
    })}); 
