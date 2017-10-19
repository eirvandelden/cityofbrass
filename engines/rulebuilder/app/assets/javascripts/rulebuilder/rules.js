// SEARCH
$(document).on('ready page:change', function () {
  var core_rules_param = getQueryVariable('core_rules');
  $('.select2-rule_type_search > optgroup').each(function () {
    if (this.label !== core_rules_param && core_rules_param !== false) {
      this.remove();
    }
  });

  if ($('.select2-rule_type_search optgroup').length < 1) {
    $('.select2-rule_type_search option:selected').remove();
  }

  $('.select2-rule_type_search').select2({
    minimumResultsForSearch: Infinity
  });
});

// NEW FORM
$(document).on('ready page:change', function () {

  $('.select2-rule_type > optgroup').each(function () {
    if (this.label !== $('select[id$="rule_core_rules"] option:selected').text()) {
      this.remove();
    }
  });

  if (typeof rule_type_param !== 'undefined') {
    $('.select2-rule_type').val(rule_type_param);
  }

  if ($('.select2-rule_type optgroup').length < 1) {
    $('.select2-rule_type option:selected').remove();
    $('.select2-rule_type').prop('disabled', true);
  }

  $('.select2-rule_type').select2({
    minimumResultsForSearch: Infinity
  });
});

// CORE RULES SELECTION
$(document).on('ready page:change', function () {
  $('select[id$="rule_core_rules"]').on('change', function () {
    $('.select2-rule_type').prop('disabled', false);
    $core_rule = this.value;
    $('.select2-rule_type > optgroup').each(function () {
      this.remove();
    });

    var optgroup = $('<optgroup/>');
    optgroup.attr('label', $core_rule);

    $.each(ruleList[$core_rule], function (index, value) {
      optgroup.append(
          $('<option></option>').html(value)
      );
    });

    $('.select2-rule_type').append(optgroup);
    $('.select2-rule_type').val($('.select2-rule_type option:first').val()).trigger('change');
  });
});
