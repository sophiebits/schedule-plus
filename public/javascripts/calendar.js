var Calendar = {
  
  init: function() {
    var start_time = 7; /* 5AM */
    var end_time = 22;  /* 10PM */
    var courses = $('#schedule .course');
    
    courses.find('.sections').hide();       /* Hide section times */
    courses.find('.options').hide();        /* Hide course options */
   
    /*
     * Create event listeners
     */
    courses.live({
      click: function() {
        /* TODO slide other courses up */
        $(this).find('.sections').slideToggle();
      },
      mouseenter: function() {
        $(this).find('.options').stop(true, true).show();
      },
      mouseleave: function() {
        $(this).find('.options').fadeOut(200);
      }
    });

    /*
     * Generate times
     */
    $('#calendar').append('<li><ul id="times"></ul></li>');
    for (var i = start_time; i <= end_time; ++i)
      $('#times').append('<li class="begin' + (i * 60) + '"> ' 
        + ((i - 1) % 12 + 1) + (parseInt(i / 12) ? 'pm' : 'am')
        + '<span class="half-hour"></span></li>');
    $('#times li:odd').addClass('alt');
  
    var days = ['M', 'T', 'W', 'R', 'F'];

    $('#calendar').append('<li id="main-schedule"><ol></ol></li>');
    for (var i = 0; i < days.length; ++i)
      $('#main-schedule ol').append('<li class="'+days[i]
        +'"><ul class="courses"></ul></li>');

    /*
     * Add courses
     */
    courses.each(function(i,c) { Calendar.addCourse(c); });
    for (var i = 0; i < days.length; ++i) {
      Calendar.layoutDay($('#main-schedule li.' + days[i] + ' .courses li'));
    }
  },

  addCourse: function(course) {

    var number = $(course).find('.number').text();

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
     
      for (var i = 0; i < dayss.length - 1; ++i) {
        var days = dayss[i].split("");
        for (var j = 0; j < days.length; ++j) {
          var start = strToMin(times[i].substr(0, times[i].indexOf("-")));
          var end = strToMin(times[i].substr(times[i].indexOf("-") + 1));
          $('<li class="event course' + number 
            + '" event-start="' + start 
            + '" event-end="' + end + '">'
            + '<span class="number">' + number + '<span>'
            + '</li>').appendTo('#calendar .' + days[j] + ' .courses');
        }
      }
    }

    place(section);
    place(lecture);
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
        $(events[at]).css("top", (3.125*(events[at].start-420)/30)+"%");
        $(events[at]).css("height", (3.125*(events[at].end-events[at].start)/30)+"%");
        $(events[at]).css("width", (134 / cols - 5)+"px");
        $(events[at]).css("left", (events[at].left * 134/cols)+"px");
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
