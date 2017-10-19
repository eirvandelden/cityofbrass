$(document).on('ready page:load', function () {
  $('[data-link]').click(function () {
    window.location = this.dataset.link;
    return;
  });
});

// feature menu items sections
$(document).on('ready page:load', function () {
  $('[type=checkbox]').change(function () {
    $checkbox = $(this);
    $icon = $checkbox.siblings('[class*=fa-times-circle]');

    checked = $checkbox.is(':checked');

    $icon.toggleClass('deleted', checked).toggleClass('', !checked);

    $('.sortable-item').addClass('disabled');
  });
});

function getQueryVariable (variable) {
  var query = window.location.search.substring(1);
  var vars = query.split('&');
  for (var i = 0; i < vars.length; i++) {
    var pair = vars[i].split('=');
    if (pair[0] === variable) { return pair[1].replace('%20', ' '); }
  }
  return (false);
}
