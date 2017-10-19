// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function new_token (_id) {
  $.ajax({
    url: '/ap/virtual_tables/' + _id + '/new_token.js',
    dataType: 'script'
  });
};
