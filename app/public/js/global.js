$(document).ready(function() {

    $(document).on('click', '.btn-add', function(e) {
        e.preventDefault();

        var phoneNumber = $('.phone-input input'),
            phoneNumbers = $('.phone'),
            phoneGroup = $('.phone-group');


        if (phoneNumber.val().length == 17 && phoneNumbers.length < 5) {
            phoneGroup.append(
                '<div class="phone-numbers row">' +
                    '<div class="col-xs-10 phone">' +
                      '<input type="text" class="form-control bfh-phone" name="phone[]" required="true" data-format="+1 (ddd) ddd-dddd" disabled>' +
                    '</div>' +
                    '<div class="col-xs-2 add-button">' +
                      '<button type="button" class="btn btn-danger btn-remove"><i class="fa fa-minus""></i></button>' +
                    '</div>' +
                '</div>'
            );
            phoneGroup.children('.phone-numbers:last').children('.phone').children('input').val(phoneNumber.val());
            phoneNumber.val('+1 ');

        } else if (phoneNumbers.length == 5) {
            $(this).parent().parent().children('.phone').children('input').prop('disabled', true);
            $(this).prop('disabled', true);
        }
        // add Remove button
        // update pay button
        // add validations
        updateAmount();
    }).on('click', '.btn-remove', function(e) {
        var phoneNumbers = $('.phone');

        $(this).parent().parent().remove();
        if (phoneNumbers.length == 5) {
            $('.btn-add').prop('disabled', false);
        }

        updateAmount();
        e.preventDefault();
        return false;
    });

    function updateAmount() {
        var phoneNumbersCount = $('.phone').length - 1,
            radioChecked = $('input[name=optionsRadios]:checked').val(),
            value = 0;

            if ($('.phone input').prop('disabled') == true) {
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
        $('input[type=submit]').val('Pay $' + (value * phoneNumbersCount).toFixed(2));

        return;
    }
});

