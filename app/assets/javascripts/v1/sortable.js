var $sort_enabled = true;

function bindSortable() {
  $(".sortable").sortable({
    placeholder: "ui-sortable-placeholder",
    items: "li:not(.ui-state-disabled)"
  }).disableSelection();

  $('.sortable').sortable().unbind('sortupdate');

  $('.sortable').sortable().bind('sortupdate', function() {
    var i=0;
    $("[name*=sort_order]").each(function() {
      $(this).val(i+=1);
    });

    $('form[data-sortable]').submit();
  });

  setLockIcon();

  $("#sortable_unlock").unbind( "click" );
  $('#sortable_unlock').on("click", function(e){
    sortable_unlock();
  });

  if(!$sort_enabled)
    sortableDisable();
}

function sortable_unlock(){
  $sort_enabled = $( ".sortable" ).sortable( "option", "disabled" );
  if($sort_enabled == true){
    sortableEnable();
  }else{
    sortableDisable();
    $("#sortable_unlock_icon").removeClass( "fa-unlock" ).addClass( "fa-lock" );
  }
  setLockIcon();
}

function sortableEnable() {
  $( ".sortable" ).sortable();
  $( ".sortable" ).sortable( "option", "disabled", false );
  $( ".sortable" ).disableSelection();
  return false;
}

function sortableDisable() {
  $( ".sortable" ).sortable("disable");
  return false;
}

function setLockIcon() {
  if($sort_enabled == true){
    $("#sortable_unlock_icon").removeClass( "fa-lock" ).addClass( "fa-unlock" );
  }else{
    $("#sortable_unlock_icon").removeClass( "fa-unlock" ).addClass( "fa-lock" );
  }
}

$(document).on('ready page:change', function () {
  if ($('#sortable_unlock').length){
    if (matchMedia(Foundation.media_queries['medium']).matches){
      $sort_enabled = true;
    }else{
      $sort_enabled = false;
    }
  }
  bindSortable();
});
