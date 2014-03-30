var Accounting = (function ($, Shared) {
    var init = function (parent, child) {
        calculate(parent, child);

        $(document).on('change', 'input[name="' + child + '-chosen"]', function () {
            if ($(this).is(":checked")) {
                Shared.toggleItemInputs(this, true);
                $(this).closest("tr").find('input[name$="[_destroy]"]').val("false");
            } else {
                Shared.toggleItemInputs(this, false);
                $(this).closest("tr").find('input[name$="[_destroy]"]').val("true");
            }
            calculate(parent, child);
        });

        $(document).on('change', 'input[name$="[amount]"]', function () {
            calculate(parent, child);
        });
    };

    var calculate = function (parent, child) {
        if ($("." + parent + "-amount:visible").size()) {
            var total = 0;
            $('tr:visible input[name="' + child + '-chosen"]:checked').each(function () {
                total += Shared.text_to_number($(this).closest("tr").find('input[name$="[amount]"]').val());
            });
            $("." + parent + "-amount:visible").html(total == 0 ? "" : Shared.number_to_currency_with_unit(total, 2, '.', ','));
        }
    };

    return {
        init: init,
        calculate: calculate
    }

})(jQuery, Shared)