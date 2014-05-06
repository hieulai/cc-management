var Receipt = (function ($, Shared, Accounting) {
    var init = function () {
        initChildren();

        $("#receipt-form").on('railsAutocomplete.select', '.receipt-item-name', function (event, data) {
            $(this).closest("tr").find("input.name").val(data.item.label);
            $(this).closest("tr").find("input.description").val(data.item.description);
        });
        $("#receipt-form").on('railsAutocomplete.select', '.receipt-people-name', function (event, data) {
            $(this).nextAll("input.payerId").val(data.item.id);
            $(this).nextAll("input.payerType").val(data.item.type);
        });

        $("#receipt-form").bind('cocoon:after-remove', function () {
            Accounting.calculate("receipt", "item");
        });

        $("#receipt-form").on('change', 'input[name="receipt[uninvoiced]"]', function () {
            $(".invoiced").toggle();
            $(".uninvoiced").toggle();
            initChildren();
        });
    };

    var initChildren = function () {
        if ($(".invoiced").is(":visible")) {
            Accounting.init("receipt", "invoice");
        } else {
            Accounting.init("receipt", "item");
        }
    }

    return {
        init: init
    }
})(jQuery, Shared, Accounting);

