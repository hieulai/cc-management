var Invoice = (function ($, Shared, Accounting) {
    var init = function () {
        Accounting.init("receipt", "invoice");

        $(document).on('change', '.invoice-items-list input.invoice-amount', function () {
            Shared.calculateSubTotals("invoice-amount");
            Shared.calculateTotals("invoice-amount");
        });

        $(document).on('change', '.invoice-items-list input[name="item-chosen"]', function () {
            if ($(this).is(":checked")) {
                Shared.toggleItemInputs(this, true);
                $(this).closest("tr").find('input[name="invoice[invoices_items_attributes][][_destroy]"]').val("false");
            } else {
                Shared.toggleItemInputs(this, false);
                $(this).closest("tr").find('input[name="invoice[invoices_items_attributes][][_destroy]"]').val("true");
            }
            Shared.calculateSubTotals("invoice-amount");
            Shared.calculateTotals("invoice-amount");
        });
    };

    return {
        init: init
    }
})(jQuery, Shared, Accounting);