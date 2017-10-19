function unlock_field (field, icon) {
  var $f = $(field);
  var $i = $(icon);
  if ($f.attr('disabled')) {
    $f.removeAttr('disabled');
    $i.removeClass('fa-lock').addClass('fa-unlock');
  } else {
    $f.attr('disabled', 'disabled');
    $i.removeClass('fa-unlock').addClass('fa-lock');
  }
}
