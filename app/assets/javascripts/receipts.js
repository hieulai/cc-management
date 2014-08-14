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

        $("#receipt-form").on('change', 'input[name="receipt[kind]"]', function () {
            $(".receipt-kind").hide();
            $("." + $(this).val()).show();
            $("#receipt-kind").attr("data-kind", $(this).val());
            initChildren();
        });
        Shared.initPeopleSelector(null, "#receipt_payor");
        Shared.initPeopleSelector(show_invoices, "#client_name");
    };

    var initChildren = function () {
        var kind = $("#receipt-kind").attr("data-kind");
        if (kind == "invoiced") {
            Accounting.init("receipt", "invoice");
        } else if (kind == "client_credit") {
        } else if (kind == "uninvoiced") {
            Accounting.init("receipt", "item");
        }
    };

    var show_invoices = function (pId, pType) {
        var kind = $("#receipt-kind").attr("data-kind");
        var $clientLink = $("#hidden_client_link");
        var href = $clientLink.attr("href");
        href = Shared.updateQueryStringParameter(href, "receipt[client_id]", pId);
        $clientLink.attr("href", href).click();
    };

    return {
        init: init
    }
})(jQuery, Shared, Accounting);

