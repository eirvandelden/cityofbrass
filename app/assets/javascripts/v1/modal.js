// Reset max-height after window resize
$(window).resize(function() {
  $('.reveal-modal-scroll').css('max-height', $('html').height() - 110 + 'px'); // 100 +10px to keep modal effect visible
});
