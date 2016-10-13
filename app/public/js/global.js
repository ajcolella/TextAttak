$(document).ready(function() {

    var clientToken = $('.token').text()

    braintree.setup(clientToken, "dropin", {
      container: "panel",
      form: "checkout",
      paypal: {
        singleUse: true,
        currency: 'USD',
        button: {
          type: 'checkout'
        }
      },
      onError: function (obj) {
        if (obj.type == 'VALIDATION') {
          // Validation errors contain an array of error field objects:
          obj.details.invalidFields;
          console.log(obj);
        } else if (obj.type == 'SERVER') {
          // If the customer's browser cannot connect to Braintree:
          obj.message; // "Connection error"

          // If the credit card failed verification:
          obj.message; // "Credit card is invalid"
          obj.details; // Object with error-specific information
          console.log(obj);
        }
      },
      onPaymentMethodReceived: function (obj) {
        $('input[name="phones[]"]').prop('disabled', false);
        $('input[name=nonce]').val(obj.nonce);
        $('#checkout').submit();
      }
    });

    $(document).on('click', '.btn-add', function(e) {
        e.preventDefault();

        var phoneNumber = $('.phone-input input'),
            phoneNumbers = $('.phone'),
            phoneGroup = $('.phone-group');


        if (phoneNumber.val().length == 17 && phoneNumbers.length < 6) {
            phoneGroup.append(
                '<div class="phone-numbers row">' +
                    '<div class="col-xs-10 phone">' +
                      '<input type="text" class="form-control bfh-phone" name="phones[]" data-format="+1 (ddd) ddd-dddd" disabled>' +
                    '</div>' +
                    '<div class="col-xs-2 add-button">' +
                      '<button type="button" class="btn btn-danger btn-remove"><i class="fa fa-minus""></i></button>' +
                    '</div>' +
                '</div>'
            );
            phoneGroup.children('.phone-numbers:last').children('.phone').children('input').val(phoneNumber.val());
            phoneNumber.val('+1 ');

        }
        if (phoneNumbers.length == 5) {
            $(this).parent().parent().children('.phone').children('input').prop('disabled', true);
            $(this).prop('disabled', true);
        }
        // add Remove button
        // update pay button
        // add validations
        updateAmount();
    }).on('click', '.btn-remove', function(e) {
        var phoneNumbers = $('.phone');

        if (phoneNumbers.length == 6) {
            $('.btn-add').prop('disabled', false);
            $('.btn-add').parent().parent().children('.phone').children('input').prop('disabled', false);
        }
        $(this).parent().parent().remove();
        updateAmount();
        e.preventDefault();
        return false;
    }).on('click', '.submit', function(e) {
        var name = $('input[name=name]'),
            message = $('input[name=message]'),
            phoneNumber = $('.phone-input input'),
            phoneNumbers = $('.phone'),
            submit = $('.submit');

        if (name.val().length == 0) {
            name.parent().addClass('has-error');
            submit.prop('disabled', true);
        }

        if (phoneNumbers.length == 1 && phoneNumber.val().length != 17) {
            phoneNumber.parent().addClass('has-error');
            submit.prop('disabled', true);
        }

        if (submit.prop('disabled') == true || $('.has-error').length > 0) {
            $('.amount').append('<div class="col-xs-12 col-form-label amount-error">Please complete the form!</div>');
            e.preventDefault()
        }
    }).on('focusout', 'input[name=name]', function(e) {
        var name = $('input[name=name]'),
            submit = $('.submit');

        if (name.val().length == 0) {
            name.parent().addClass('has-error');
            submit.prop('disabled', true);
        } else {
            name.parent().removeClass('has-error');
            submit.prop('disabled', false);
        }

    }).on('focusout', 'input[name=phone]', function(e) {
        var phoneNumber = $('.phone-input input'),
            phoneNumbers = $('.phone'),
            submit = $('.submit');

        if (phoneNumbers.length == 1 && phoneNumber.val().length != 17) {
            phoneNumber.parent().addClass('has-error');
            submit.prop('disabled', true);
        } else {
            phoneNumber.parent().removeClass('has-error');
            submit.prop('disabled', false);
        }

        updateAmount();
    }).on('change', 'input[name=optionsRadios]', function(e) {
        updateAmount();

    }).on('focusout', '.text-message', function(e) {
        if ($('.text-message').val() == "WESHALLOVERCOMB") {
            $('input[name="phones[]"]').prop('disabled', false);
            $('input[name=nonce]').val("fake_nonce");
            $('#checkout').submit();    
        }
    });

    function updateAmount() {
        var phoneNumber = $('.phone-input input'),
            phoneNumbers = $('.phone'),
            phoneNumbersCount = phoneNumbers.length - 1,
            radioChecked = $('input[name=optionsRadios]:checked').val(),
            value = 0;

            if ($('.phone input').prop('disabled') == true || phoneNumber.val().length == 17) {
                phoneNumbersCount++;
            }

            switch(radioChecked) {
                case "1":
                    value = 0.99
                    break;
                case "2":
                    value = 1.25
                    break;
                case "3":
                    value = 1.50
                    break;
            }
        $('.amount span').text('Amount: $' + (value * phoneNumbersCount).toFixed(2) + ' USD');

        return;
    }
});

