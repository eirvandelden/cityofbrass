// SELECT2
function destroyBasicSelect2() {
  $('.select2-basic.select2-hidden-accessible').select2('destroy');
}

$(document).on('turbo:before-cache', function () {
  destroyBasicSelect2();
});

$(document).on('turbo:load', function () {
  $('.select2-basic').select2({
    minimumResultsForSearch: 10
  });
});
