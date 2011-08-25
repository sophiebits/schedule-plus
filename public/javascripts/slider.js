var slide = [];
function initSlider(div,ul,li,pos) {
  var slides = $(div + ' ' + ul + ' '+ li);
  slide[div] = pos;
  $(div + ' ' + ul).css({
    width:slides.length + '00%',
    left:-pos * 100 + '%'
  });
  $(div + ' .nav-previous').addClass('disabled');
  $(div + ' .nav-previous,' + div + ' .nav-next').click(function() {
    if ($(this).hasClass('disabled')) exit();
    sliderDiv = $(this).closest('div');
    slideContainer = sliderDiv.children().eq(0);
    navPrev = $('#' + sliderDiv.attr('id') + ' .nav-previous');
    navNext = $('#' + sliderDiv.attr('id') + ' .nav-next');
    
    oldSlide = slide['#' + sliderDiv.attr('id')];
    
    // enable controls
    if (oldSlide == 0)
      navPrev.removeClass('disabled');
    else if (oldSlide == slideContainer.children().length - 1)
      navNext.removeClass('disabled');

    currentSlide = oldSlide + ($(this).hasClass('nav-previous') ? -1 : 1);
    slide['#' + sliderDiv.attr('id')] = currentSlide;
    
    // disable controls
    if (currentSlide == 0)
      navPrev.addClass('disabled');
    else if (currentSlide == slideContainer.children().length - 1)
      navNext.addClass('disabled');
    
    sliderDiv.children().eq(0).animate({ 
      left: -currentSlide * 100 + '%'
    }, 300);
    /*
    if ($(this).hasClass('nav-previous')) {
      alert('prev');
    } else {
      alert('next');
      sliderDiv.children().eq(0).animate({
        
      });
    }
    */
  });
}
