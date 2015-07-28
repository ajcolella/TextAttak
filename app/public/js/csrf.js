$(document).on('submit', 'form', function() {
  var form, method, token;
  form = $(this);
  method = form.attr('method').toUpperCase();
  token = $('meta[name=csrf-token]').attr('content');
  if ((method != null) && method !== 'GET') {
    return form.prepend($('<input>', {
      name: '_csrf',
      type: 'hidden',
      value: token
    }));
  }
});