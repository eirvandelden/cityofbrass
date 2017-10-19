function removeForm() {
  $('#form_div').remove();
  $('#form_modifier_div').remove();
  $('#form_modifier_placeholder').remove();
  $('#form_placeholder').show()
}

function removeFormModifiers() {
  $('#form_div_mod').remove();
  $('#form_placeholder_mod').show()
  $('#form_modifier_div').remove();
  $('#form_modifier_placeholder').show();
}
