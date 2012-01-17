var Slideshow = {

  speed: 400,
  slide_width: 620,
  current_slide: 0,
  slides: null,
  num_slides: 0,
 
  init: function() {
    
    Slideshow.slides = $('.slideshow .slide-container .slide');
    Slideshow.num_slides = Slideshow.slides.length;
  
    // create .control elements 
    $('.slideshow').append(
      '<span class="control last">last</span>\
       <span class="control next">next</span>');
    
    // create links to slides 
    $('.slideshow').append('<ul class="slide-links"></ul>');
    $.each(Slideshow.slides, function() {
      var title = $(this).attr('title');
      $('.slideshow .slide-links').
        append('<li class="control" title="'+title+'">'+title+'</li>');
    });
    
    // set container widths 
    $('.slideshow .slide-container').width(Slideshow.num_slides * Slideshow.slide_width);
    $('.slideshow .slide-links').css({
      width:Slideshow.num_slides * 20, 
      left: Slideshow.slide_width/2 - 5 - Slideshow.num_slides*10
    });
  
    /* event listener for .control clicks */
    $('.slideshow .control').click(function() {
      if ($(this).attr('class') == 'control next') {
        Slideshow.current_slide += 1;
      } else if ($(this).attr('class') == 'control last') {
        Slideshow.current_slide -= 1;
      } else {
        Slideshow.current_slide = $('.slideshow .slide-links .control').index($(this));
      }
      if (Slideshow.current_slide == Slideshow.num_slides) Slideshow.current_slide = 0;
      if (Slideshow.current_slide < 0) Slideshow.current_slide = Slideshow.num_slides-1;
      
      //location.hash = '#'+slides.eq(Slideshow.current_slide).attr('title');
     
      Slideshow.refresh(Slideshow.speed);
    });
    
    /* control mouseover styles */
    $('.slideshow .slide-links .control').mouseover(function() {
      if ($(this).index() != Slideshow.current_slide)
        $(this).css('opacity', '0.6');
    }).mouseout(function() {
      if ($(this).index() != Slideshow.current_slide)
        $(this).css('opacity', '0.4');
    });

    Slideshow.refresh(Slideshow.speed);
  },
  
  /* show/hide and set control styles */
  manage_controls: function() {
    $('.slideshow .control').show();
    if (Slideshow.current_slide == 0) $('.slideshow .control.last').hide();
    if (Slideshow.current_slide == Slideshow.num_slides-1) $('.slideshow .control.next').hide();
  
    $('.slideshow .slide-links .control')
      .stop().css('opacity', '0.4');
    $('.slideshow .slide-links .control').eq(Slideshow.current_slide)
      .animate({opacity:1.0}, Slideshow.speed);
  },
  
  refresh: function(speed) {
    // Perform slide-specific entrance animations
    switch (Slideshow.current_slide) {
      case 0:
        $('#home-tagline img').css({ top:0, opacity:0 })
                              .delay(speed/2)
                              .animate({ top:'-60px', opacity:1 });
      default:
        $(Slideshow.slides[Slideshow.current_slide]).find('.home-img')
                              .css({ top:'50px', opacity:0 })
                              .delay(speed/2)
                              .animate({ top:0, opacity:1 });
    }
    $('.slideshow .slide-container')
      .stop().animate({left:Slideshow.current_slide * -Slideshow.slide_width}, speed);
    for (var i = 0; i < Slideshow.num_slides; ++i) {
      if (i == Slideshow.current_slide)
        $(Slideshow.slides[i]).animate({opacity:1.0}, 2*speed);
      else
        $(Slideshow.slides[i]).animate({opacity:0.0}, speed/2);
    }
    Slideshow.manage_controls();
  }

};

$(function() {
  Slideshow.init();
});
