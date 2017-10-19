/*// Set max-height the first time
$(document).on('ready page:load', function () {
  $('.reveal-modal').css('max-height', $('html').height() - 70 + 'px'); // 100 +10px to keep modal effect visible
  $('.reveal-modal-scroll').css('max-height', $('html').height() - 210 + 'px'); // 100 +10px to keep modal effect visible
});
*/

$(document).on('ready page:load', function () {
  $(".image-pick-list").click(function() {
    $("#"+image_for).val($(this).attr('id'));
    $("#record_img").attr("src", $(this).attr("data-url"));
    $('#pkrGalleryModal').foundation('reveal', 'close');
  });
});

function set_image_blank(img){
  $("#"+image_for).val($(this).attr('id'));
  $("#record_img").attr("src", img);
};
