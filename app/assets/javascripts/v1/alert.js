$(document).on('ready page:load', function () {
  var clearAlert = setTimeout(function(){
    $(".alert-box").fadeOut('slow')
  }, 2000);

  $(document).on("click", ".alert-box a.close", function(event){
    clearTimeout(clearAlert);
  });

  $(document).on("click", ".alert-box a.close", function(event) {
    event.preventDefault();
    $(this).closest(".alert-box").fadeOut(function(event){
      $(this).remove();
    });
  });
});

// AJAX FLASH NOTICE ANIMATION
$( document ).ajaxComplete(function(event, xhr) {
  //show_ajax_message(); //use whatever popup, notification or whatever plugin you want
  var clearAlert = setTimeout(function(){
    $(".alert-box").fadeOut('slow')
  }, 2000);

  $(document).on("click", ".alert-box a.close", function(event){
    clearTimeout(clearAlert);
  });

  $(document).on("click", ".alert-box a.close", function(event) {
    event.preventDefault();
    $(this).closest(".alert-box").fadeOut(function(event){
      $(this).remove();
    });
  });
});
