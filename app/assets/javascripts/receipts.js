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
    };

    var initChildren = function () {
        var kind = $("#receipt-kind").attr("data-kind");
        if (kind == "invoiced") {
            Accounting.init("receipt", "invoice");
            $(".client-select .controls").html($("#invoiced-client-select").html());
        } else if (kind == "client_credit") {
            $(".client-select .controls").html($("#client_credit-client-select").html());
        } else if (kind == "uninvoiced") {
            Accounting.init("receipt", "item");
            $(".client-select .controls").html("");
        }
        $('.client-select select').select2({
            width: "220px",
            placeholder: "",
            allowClear: true
        });

    }

    return {
        init: init
    }
})(jQuery, Shared, Accounting);

