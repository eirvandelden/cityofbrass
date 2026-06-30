$(document).on('turbolinks:load', function () {

  $('#selectEngineWB').change(function () {
    if ($(this).data('options') === undefined) {
      $(this).data('options', $('#selectRecordType option').clone());
    }
    var id = $(this).val();

    if (id === 'WB') {
      base_url = district_url;
    } else {
      base_url = resident_url;
    }

    var options = $(this).data('options').filter('[value=' + id + ']');
    $('#selectRecordType').html(options).trigger('change');

  });

  $('#selectEngineSB').change(function () {
    var engine = $('#selectEngineSB option:selected').val();
    var i;

    if (engine === 'CM') {
      var categories = [
        {name: 'Adventure Logs', path: cm_url + 'adventure_logs.json'},
        {name: 'House Rules', path: cm_url + 'house_rules.json'},
        {name: 'GM Notes', path: cm_url + 'game_master_notes.json'},
        {name: 'Pages', path: cm_url + 'pages.json'}
      ];
      $('#selectParent option').remove();
      for (i = 0; i < categories.length; i++) {
        $('#selectParent').get(0).options.add(new Option(categories[i].name, categories[i].path));
      }
      $('#selectParent').trigger('change');
      return;
    }

    var engine_url;
    if (engine === 'WB') {
      engine_url = wb_url + 'districts.json';
    } else {
      engine_url = sb_url + 'adventures.json?order=wizard';
    }

    $.ajax({
      url: engine_url,
      dataType: 'json',
      success: function (data) {
        var i;
        $('#selectParent option').remove();
        for (i = 0; i < data.length; i++) {
          $('#selectParent').get(0).options.add(new Option(data[i].name, data[i].path));
        }
        $('#selectParent').trigger('change');
      }
    });
  });

  $('#selectParent').change(function () {
    var id = $('#selectEngineSB option:selected').val();
    var parent_url = $('#selectParent option:selected').val();

    if (id === 'CM') {
      $.ajax({
        url: parent_url,
        dataType: 'json',
        success: function (data) {
          var i;
          $('#selectRecord option').remove();
          for (i = 0; i < data.length; i++) {
            $('#selectRecord').get(0).options.add(new Option(data[i].name, data[i].path));
          }
        }
      });
      return;
    }

    if ($(this).data('options') === undefined) {
      $(this).data('options', $('#selectRecordType option').clone());
    }
    var options = $(this).data('options').filter('[value=' + id + ']');
    $('#selectRecordType').html(options).trigger('change');
  });

  $('#selectRecordType').change(function () {
    var rec_type = $('#selectRecordType option:selected').text().toLowerCase().replace(' ', '_');
    var rec_url = parent_url + '/' + rec_type + '.json';

    $.ajax({
      url: rec_url,
      dataType: 'json',
      success: function (data) {
        var i;
        $('#selectRecord option').remove();
        for (i = 0; i < data.length; i++) {
          $('#selectRecord').get(0).options.add(new Option(data[i].name, data[i].path));
        }
      }
    });
  });

  $('#menu-select').click(function () {
    var return_tb = $('#wizard_for').val();
    var return_val = $('#selectRecord option:selected').val();
    $('#' + return_tb).val(return_val);
    $('#menuWizardModal').foundation('reveal', 'close');
  });
});

function setWizardFor (data) {
  $('#wizard_for').val(data);
  $('#selectEngine' + engine_type).val(engine_type);
  $('#selectEngine' + engine_type).change();
}
