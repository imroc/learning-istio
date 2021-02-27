(function ($) {
	'use strict';

	// Blog Img
	$('.article-style img').on('click', function (e) {
		BigPicture({
			el: e.target,
		})
	})

	console.log("hello")

})(jQuery);