var TimeStamp = function () {
  $('[data-timestamp]').each(function () {
    if ($(this).data('timestamp') > 0) {
      var local = new moment(new Date($(this).data('timestamp')));
      if ($(this).data('timestamp-format')) {
        var format = $(this).data('timestamp-format');
        $(this).text(local.format(format));
      } else {
        $(this).text(local.calendar(null, {sameElse: 'MMMM Do YYYY'}));
      }
    }
  });
};

$(document).on('page:change', function () {
  TimeStamp();
});

$(document).ajaxComplete(function (event, xhr) {
  TimeStamp();
});
