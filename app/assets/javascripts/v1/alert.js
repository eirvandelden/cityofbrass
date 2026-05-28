$(document).on('turbolinks:load', function () {
  var clearAlert = setTimeout(function(){
    $(".alert-box").fadeOut('slow')
  }, 2000);

  bindAlertCloseHandlers(clearAlert);
});

// AJAX FLASH NOTICE ANIMATION
$( document ).ajaxComplete(function(event, xhr) {
  //show_ajax_message(); //use whatever popup, notification or whatever plugin you want
  var clearAlert = setTimeout(function(){
    $(".alert-box").fadeOut('slow')
  }, 2000);

  bindAlertCloseHandlers(clearAlert);
});

function bindAlertCloseHandlers(clearAlert) {
  $(document).off('click.alertBox', '.alert-box a.close');
  $(document).on('click.alertBox', '.alert-box a.close', function(event) {
    event.preventDefault();
    clearTimeout(clearAlert);
    $(this).closest(".alert-box").fadeOut(function(event){
      $(this).remove();
    });
  });
}
