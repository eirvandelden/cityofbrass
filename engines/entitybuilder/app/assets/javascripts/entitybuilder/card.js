function eb_display_card (_id, _url) {
  $('.eb-v1-card-panel').hide();
  $('#ap-panel-entity-link').click();

  if ($('#card_' + _id).length) {
    $('#card_' + _id).show();
  } else {
    $('#cardholder_div').show();
    eb_get_card(_url);
  }
}

function eb_get_card (_url) {
  $('.eb-v1-status-refresh i').addClass('fa-spin');
  $.ajax({
    url: _url,
    dataType: 'script'
  });
};
