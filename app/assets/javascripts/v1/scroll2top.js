$(document).on('turbo:load', function () {
	// Show or hide the sticky footer button
	$(window).off('scroll.scroll2top');
	$(window).on('scroll.scroll2top', function() {
		if ($(this).scrollTop() > 200) {
			$('.go-top').fadeIn(200);
		} else {
			$('.go-top').fadeOut(200);
		}
	});

	// Animate the scroll to top
	$('.go-top').off('click.scroll2top');
	$('.go-top').on('click.scroll2top', function(event) {
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
