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

function fill_unlocked (field, icon, value) {
  $(field).removeAttr('disabled').val(value);
  $(icon).removeClass('fa-lock').addClass('fa-unlock');
}

function prefill_power () {
  var usage = $('#attack_power_usage').val();
  if (!usage) { return; }
  var multi_target = $('#attack_multi_target').is(':checked');
  var usable_at_will = $('#attack_usable_at_will').is(':checked');
  var match = $('#power_fields').data('prefill').filter(function (option) {
    return option.usage === usage && option.multi_target === multi_target &&
      option.usable_at_will === usable_at_will;
  })[0];
  if (!match) { return; }
  fill_unlocked('#attack_attack_bonus', '#icon_unlock_attack', match.attack_bonus);
  fill_unlocked('#attack_damage_bonus', '#icon_unlock_damage', match.damage_bonus);
}
