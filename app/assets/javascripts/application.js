// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require foundation
//= require chance.v1.0.2
//= require moment.min
//= require jquery-ui-1.11.4.custom
//= require jquery.ui.touch-punch
//= require select2

//= require_tree ./v1
//= require_tree ./time
//= require_tree ./roller
//= require ckeditor/brassify
//= require gallery/image-picker
//= require billing/subscriptions
//= require entitybuilder/application
//= require rulebuilder/application
//= require activeplay/application


$(document).on('ready page:load', function () {
  $(document).foundation();

  $('.popbox').popbox();

  $(document).on('closed.fndtn.reveal', '[data-reveal]', function () {
    var modal = $(this);

    // deprecated: this will get removed after modal migration
    if (modal.attr('id') === 'showModal' || modal.attr('id') === 'sheetModal') {
      $('#show_div').remove();
      $('#show_placeholder').show();
    }

    if(modal.attr('id').indexOf("_modal") > 0){
      m = modal.attr('id').replace('_modal', '');
      $('#' + m + '_div').remove();
      $('#' + m + '_placeholder').show();
    }
  });

  Turbolinks.enableTransitionCache();
  Turbolinks.enableProgressBar();

});


$(document).on('page:change', function () {
  //FIX OFFSCREEN/BODY SO ITS 100% HIEGHT
  $(function() {
    var timer;

    $(window).resize(function() {
      clearTimeout(timer);
      timer = setTimeout(function() {
        $(document).foundation('equalizer', 'reflow'); // fixes reflow on elements with images
        $('.inner-wrap').css("min-height", $(window).height() - 102 + "px" );
      }, 40);
    }).resize();
  });
});
