$('#modifier_category').change(function() {

  $("#modifier_item").prop( "disabled", true );
  $("#modifier_item").css("cursor", "wait");

  var rec_type = $("#modifier_category option:selected").text().toLowerCase().replace(" ","_");
  var rec_url = base_url + rec_type + ".json";

  if(rec_type == 'all_attacks'){
    $("#modifier_item option").remove();
    $("#modifier_item").get(0).options.add(new Option('Attack'));
    $("#modifier_item").get(0).options.add(new Option('Melee Attack'));
    $("#modifier_item").get(0).options.add(new Option('Range Attack'));
    $("#modifier_item").get(0).options.add(new Option('Damage'));
    $("#modifier_item").get(0).options.add(new Option('Critical Damage'));
    $("#modifier_item").get(0).options.add(new Option('Special Damage'));
  }else{
    $("#modifier_item option").remove();
    $.ajax({
      url: rec_url,
      dataType: "json",
      success: function(data) {
        var i;
        for (i = 0; i < data.length; i++) {
          $("#modifier_item").get(0).options.add(new Option(data[i].name));
        }
      }
    });
  }

  $("#modifier_item").prop( "disabled", false );
  $("#modifier_item").css("cursor", "default");

});
