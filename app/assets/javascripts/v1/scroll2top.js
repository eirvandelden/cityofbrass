$(document).on('ready page:change', function () {
	// Show or hide the sticky footer button
	$(window).scroll(function() {
		if ($(this).scrollTop() > 200) {
			$('.go-top').fadeIn(200);
		} else {
			$('.go-top').fadeOut(200);
		}
	});

	// Animate the scroll to top
	$('.go-top').click(function(event) {
		event.preventDefault();
		$('html, body').animate({scrollTop: 0}, 300);
	})
});

function scrollToForm(scrollToMe){
	if (matchMedia(Foundation.media_queries['medium']).matches){
		$('html, body').animate({scrollTop: 0}, 300);
	}else{
		$('html, body').animate({scrollTop: $(scrollToMe).offset().top}, 300);
	};
}
