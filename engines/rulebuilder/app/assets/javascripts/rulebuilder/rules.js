// SEARCH
$(document).on('turbo:load', function () {
  var core_rules_param = getQueryVariable('core_rules');
  $('.rule-type-search > optgroup').each(function () {
    if (this.label !== core_rules_param && core_rules_param !== false) {
      this.remove();
    }
  });

  if ($('.rule-type-search optgroup').length < 1) {
    $('.rule-type-search option:selected').remove();
  }
});

// NEW FORM
$(document).on('turbo:load', function () {
  updateRuleTypeOptions();

  $('select[id$="rule_core_rules"]').off('change.ruleTypeSelect');
  $('select[id$="rule_core_rules"]').on('change.ruleTypeSelect', updateRuleTypeOptions);
});

function selectedCoreRules() {
  return $('select[id$="rule_core_rules"]').val();
}

function updateRuleTypeOptions() {
  var select = $('.rule-type-select');
  if (select.length < 1 || typeof ruleList === 'undefined') {
    return;
  }

  var coreRules = selectedCoreRules();
  var rules = ruleList[coreRules] || [];
  var selectedRuleType = select.val();

  if (!selectedRuleType && typeof rule_type_param !== 'undefined') {
    selectedRuleType = rule_type_param;
  }

  select.empty();

  if (rules.length < 1) {
    select.prop('disabled', true);
    return;
  }

  select.prop('disabled', false);

  $.each(rules, function (index, value) {
    select.append($('<option></option>').val(value).html(value));
  });

  if (rules.indexOf(selectedRuleType) >= 0) {
    select.val(selectedRuleType);
  }
}
