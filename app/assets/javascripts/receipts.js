var Receipt = (function ($, Shared, Accounting) {
    var init = function () {
        initChildren();
        var $form = $("#receipt-form");

        $form.on('railsAutocomplete.select', '.receipt-item-name', function (event, data) {
            $(this).closest("tr").find("input.name").val(data.item.label);
            $(this).closest("tr").find("input.description").val(data.item.description);
        });
        $form.on('railsAutocomplete.select', '.receipt-people-name', function (event, data) {
            $(this).nextAll("input.payerId").val(data.item.id);
            $(this).nextAll("input.payerType").val(data.item.type);
        });
        $form.bind('cocoon:after-remove', function () {
            Accounting.calculate("receipt", "item");
        });
        $form.on('change', 'input[name="receipt[kind]"]', function () {
            $(".receipt-kind").hide();
            $("." + $(this).val()).show();
            $("#receipt-kind").attr("data-kind", $(this).val());
            initChildren();
        });
        $form.on('change', 'input[name="receipt[job_costed]"]', function () {
            $(".job_costed").toggle();
            if (!$(this).is(":checked")) {
                showInvoices($('input[name="receipt[client_id]"]').val());
            }
        });
        $form.on('change', 'select[name="receipt[estimate_id]"]', function () {
            showInvoices($('input[name="receipt[client_id]"]').val(), $(this).val());
        });

        $form.on('change', 'input[name="receipt[applied_amount]"]', function(){
            applyAmounts();
        });

        Shared.initPeopleSelector(null, "#receipt_payor");
        Shared.initPeopleSelector(showInvoicesForReceipt, "#client_name");
        applyAmounts();
    };

    var initChildren = function () {
        var kind = $("#receipt-kind").attr("data-kind");
        if (kind == "uninvoiced") {
            Accounting.init("receipt", "item");
        }
    };

    var showInvoicesForReceipt = function (pId, pType) {
        showInvoices(pId);
    };

    var showInvoices = function (clientId, estimateId) {
        var $clientLink = $("#hidden_client_link");
        var url = $clientLink.data("template-url");
        if (estimateId != null)
            url = Shared.updateQueryStringParameter(url, "receipt[estimate_id]", estimateId);
        if (clientId != null)
            url = Shared.updateQueryStringParameter(url, "receipt[client_id]", clientId);
        $clientLink.attr("href", url).click();
    };

    var applyAmounts = function(){
        clearAppliedAmounts();
        var amountS = $('input[name="receipt[applied_amount]"]').val().trim();
        var amount = parseFloat(amountS);
        if (isNaN(amount))
            return;
        var clientBalance = Shared.text_to_number($(".previous_client_balance").text());
        var newClientBalance = clientBalance - amount;
        $('.new_client_balance').html(Shared.number_to_currency_with_unit(newClientBalance, 2, '.', ','));
        var invoices = $('tr.invoice-row').toArray();
        while (amount > 0 && invoices.length > 0) {
            var invoice = invoices.shift();
            var remainingAmount = Shared.text_to_number($(invoice).find("td .remaining-amount").text());
            var billedAmount = amount >= remainingAmount ? remainingAmount : amount;
            $(invoice).find('td .billed-amount').html(Shared.number_to_currency_with_unit(billedAmount, 2, '.', ','));
            if (billedAmount == remainingAmount) {
                $(invoice).addClass("unclickable");

            }
            amount -= billedAmount;
        }
        Shared.calculateTotals("billed-amount");
    };

    var clearAppliedAmounts = function () {
        $('tr.invoice-row').each(function (index, row) {
            $(row).removeClass("unclickable");
            $(row).find('td .billed-amount').html("");
        });
    };

    return {
        init: init,
        applyAmounts: applyAmounts
    }
})(jQuery, Shared, Accounting);

