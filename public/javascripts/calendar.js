var Calendar = {
    
  start_time: 7, 
  end_time: 23, 
  half_height: 22,
  day_width: 126,
  container_width: 640,

  colors: ["rgb(250,62,84)", "rgb(255,173,64)", "rgb(56,178,206)",
           "#00b454", "rgb(179,59,212)", 
           "rgb(231,58,149)", "#bf4e30",  "#04819e"],
  used_colors: 0,

  init: function() {
    var courses = $('#schedule .course');
    
    courses.find('.sections').hide();       /* Hide section times */
    courses.find('.options').hide();        /* Hide course options */
   
    /*
     * Create event listeners
     */
    $('#schedule .course, #calendar .event').live({
      click: function(event) {
        var number = $(this).find('.number').text().trim();
        var open = !$(this).hasClass('open');
        $('#schedule').find('.sections').stop(true,true).slideUp();
        $('#schedule').find('.friends .facebox, .friends .section-header').stop(true,true).slideUp();
        $('.open').removeClass('open');
        if (open) {
          $('.course'+number).find('.friends .facebox, .friends .section-header').slideDown();
          $('.course'+number).addClass('open');
        }
      },
      mouseenter: function() {
        $('.highlight').removeClass('highlight');
        $('.course'+$(this).find('.number').text().trim()).addClass('highlight');
      },
      mouseleave: function() {
        $('.highlight').removeClass('highlight');
      }
    });

    $('#schedule .course .course-times-link').live({
      click: function(event) {
        event.stopPropagation();
        var number = $(this).closest('.course').find('.number').text().trim();
        var open = !$(this).closest('.course').hasClass('open');
        $('#schedule').find('.sections').stop(true,true).slideUp();
        $('#schedule').find('.friends .facebox, .friends .section-header').stop(true,true).slideUp();
        $('.open').removeClass('open');
        if (open) {
          $('.course'+number).find('.sections').slideDown();
          $('.course'+number).addClass('open');
        }
      }
    });
    $('#schedule .course .course-info-link, #schedule .course .number a').live({
      click: function(event) {
        event.stopPropagation();
      }
    });

    /*
     * Generate times
     */
    $('#calendar').append('<li><ul id="times"></ul></li>');
    for (var i = Calendar.start_time; i <= Calendar.end_time; ++i)
      $('#times').append('<li style="height:'
        + (2*Calendar.half_height) + 'px;top:'
        + ((i-Calendar.start_time)*2*Calendar.half_height) + 'px"> ' 
        + ((i - 1) % 12 + 1) + (parseInt(i / 12) ? ' PM' : ' AM')
        + '<span class="half-hour"></span></li>');
    $('#times li:odd').addClass('alt');
  
    var days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];

    $('#calendar').append('<li id="main-schedule"><ol></ol></li>');
    for (var i = 0; i < days.length; ++i)
      $('<li class="'+days[i]
        +'"><span class="day-label">'+days[i]+'</span><ul class="courses"></ul></li>')
        .css({
          "width":(Calendar.day_width-1)+"px",
          "height":(Calendar.half_height*(Calendar.end_time-Calendar.start_time)*2)+"px"
        })
        .appendTo('#main-schedule ol');

    /*
     * Add courses
     */
    courses.each(function(i,c) { 
      Calendar.color(c);
      Calendar.addCourse(c); 
    });
    $('.open').removeClass('open');
    for (var i = 0; i < days.length; ++i) {
      Calendar.layoutDay($('#main-schedule li.' + days[i] + ' .courses li'));
    }
  },

  color: function(course) {
    var i = 0;
    while (1 & (Calendar.used_colors >> i)) i++;
    Calendar.used_colors ^= 1 << i;
    $(course).css("border-left-color", Calendar.colors[i]);
    $(course).attr("color-index", i);
  },

  addCourse: function(course) {

    $(course).find('.friends .section-header, .friends .facebox').hide();

    var number = $(course).find('.number').text().trim();

    var section = $(course).find('.selected');
    var lecture = $(section).prevAll('.lecture').first();

    function strToMin(s) {
      var ampm = s.substr(s.length - 2);
      var rest = s.substr(0, s.length - 2);
      var hr = rest.substr(0, rest.indexOf(":"));
      var min = rest.substr(rest.indexOf(":") + 1);
      return (ampm == "pm" ? 12*60 : 0) + (parseInt(hr)%12)*60 + parseInt(min);
    }
    
    function place(e) {
      var dayss = $.trim(e.find('.days').html()).split('<br>');
      var times = $.trim(e.find('.times').html()).split('<br>');
      var locs = $.trim(e.find('.locations').html()).split('<br>');

      var section = $.trim(e.find('.lecture-num').html()) +
                    $.trim(e.find('.section-ltr').html());

      var day_map = { "M":"monday","T":"tuesday","W":"wednesday","R":"thursday","F":"friday" };

      for (var i = 0; i < dayss.length - 1; ++i) {
        var days = dayss[i].split("");
        for (var j = 0; j < days.length; ++j) {
          var start = strToMin(times[i].substr(0, times[i].indexOf("-")));
          var end = strToMin(times[i].substr(times[i].indexOf("-") + 1));
          $('<li class="event open course' + number 
            + '" event-start="' + start 
            + '" event-end="' + end + '">'
            + '<span class="number">' + number + '</span>'
            + '<span class="section">' + section + '</span>'
            + '<span class="location">' + locs[i] + '</span>'
            + '</li>').css({
              'opacity': 0,
              'border-left-color': $(course).css("border-left-color"),
            }).appendTo('#calendar .' + day_map[days[j]] + ' .courses');
        }
      }
    }

    place(section);
    place(lecture);
  },

  delete: function(d) {
    Calendar.used_colors ^= 1 << $('#schedule').find(d).attr('color-index');
    $(d).fadeOut().remove();
    var days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
    for (var i = 0; i < days.length; ++i) {
      Calendar.layoutDay($('#main-schedule li.' + days[i] + ' .courses li'));
    }
  },

  layoutAll: function() {
    /* TODO */
  },

  layoutDay: function(events) {
    
    events.each (function(i, e) {
      e.start = parseInt($(e).attr("event-start"));
      e.end = parseInt($(e).attr("event-end"))+10;
    });

    var conflicts = new List();
    var max_cols = 0, at = 0;

    function process(to, cols) {
      for (; at < to; at++) {
        var dur = events[at].end-events[at].start;
        $(events[at]).css({
          top: (Calendar.half_height*(events[at].start-Calendar.start_time*60)/30-1)+"px",
          height: (Calendar.half_height*dur/30-5)+"px"
        });
        $(events[at]).animate({
          width: (Calendar.day_width/cols-5)+"px",
          left: (events[at].left * Calendar.day_width/cols-1)+"px",
          opacity: 1
        });
      }
    }

    events.sort(function (e1, e2) { return e1.start - e2.start });
    
    for (var i = 0; i < events.length; i++) {
      conflicts.filter(function(e) { return e.end > events[i].start });
      if (conflicts.empty()) {
        process(i, max_cols);
        max_cols = 0;
      }
      max_cols = Math.max(max_cols, conflicts.insert(events[i]) + 1);
    }
    process(events.length, max_cols);
  }
};

// A List class to hold overlapping events
function List() {
  var root = null;

  this.empty = empty;
  this.insert = insert;
  this.filter = filter;

  function empty() {
    return root == null;
  }

  function shift(l) {
    if (l.next && l.e.left == l.next.e.left) {
      var tmp = l.next.e;
      l.next.e = l.e;
      l.e.left++;
      l.e = tmp;
      return shift(l.next);
    }
    return l.e.left;
  }

  function insert(e) {
    var l = new ListNode(e);
    l.next = root;
    root = l;
    e.left = 0;
    return shift(root);
  }

  function filter(p) {
    if (root) {
      root = root.filter(p);
    }
  }
}

function ListNode(elem) {
  this.e = elem;
  this.next = null;

  this.filter = filter;

  function filter(p) {
    if (this.next) {
      this.next = this.next.filter(p);
    }
    if (p(this.e)) {
      return this;
    } else {
      return this.next;
    }
  }
}

$(function() {
  Calendar.init();
});
