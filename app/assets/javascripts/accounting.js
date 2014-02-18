var calculatePurchaseAmount = function (obj, f) {
    var estimateCost = $(obj).closest("tr").find('input[name$="[][estimated_cost]"]');
    var qty = $(obj).closest("tr").find('input[name$="[][qty]"]');
    if (estimateCost.size() > 0 && qty.size() > 0) {
        var eValue = text_to_number($(estimateCost).val());
        var qValue = text_to_number(qty.val());
        var pValue = eValue * qValue;
        var placeHolder = $(obj).closest("tr").find(".actual-amount-placeholder");
        if (placeHolder.find(".actual-amount").size() > 0) {
            placeHolder.find(".actual-amount").text(number_to_currency_with_unit(pValue, 2, '.', ','));
        } else {
            placeHolder.prepend('<div class="actual-amount">' + number_to_currency_with_unit(pValue, 2, '.', ',') + '</div>');
        }
        calculatePostTaxAmount($(placeHolder).find(".actual-amount"));
    }
};

var calculatePurchasableSubTotalAndTotal = function () {
    if ($("#total").size() > 0) {
        var subtotal = 0;
        var empty = true;
        $('.actual-amount:visible').each(function () {
            var value = $(this).is("input") ? $(this).val() : $(this).text();
            if (value.trim() != "" && empty) {
                empty = false;
            }
            subtotal += text_to_number(value);
        });
        fillValue("#subtotal", subtotal, empty);
        var total = subtotal;
        if ($('input[name$="[sales_tax_rate]"]').size() > 0) {
            var salesTax = subtotal * text_to_number($('input[name$="[sales_tax_rate]"]').val()) / 100;
            $('#sales_tax').html(salesTax == 0 ? "" : number_to_currency_with_unit(salesTax, 2, '.', ','));
            total += salesTax;
            if (salesTax) {
                empty = false;
            }
        }
        if ($('input[name$="[shipping]"]').size() > 0) {
            var shipping = text_to_number($('input[name$="[shipping]"]').val());
            total += shipping;
            if (shipping) {
                empty = false;
            }
        }
        fillValue("#total", total, empty);
    }
};

var calculateAccounting = function (parent, child) {
    if ($("#" + parent + "-amount:visible").size()) {
        var total = 0;
        $('tr:visible input[name="' + child + '-chosen"]:checked').each(function () {
            total += text_to_number($(this).closest("tr").find('input[name$="[amount]"]').val());
        });
        $("#" + parent + "-amount").html(total == 0 ? "" : number_to_currency_with_unit(total, 2, '.', ','));
    }
};

var initAccounting = function (parent, child) {
    calculateAccounting(parent, child);
    $(document).on('change', 'input[name="' + child + '-chosen"]', function () {
        if ($(this).is(":checked")) {
            toggleItemInputs(this, true);
            $(this).closest("tr").find('input[name$="[_destroy]"]').val("false");
        } else {
            toggleItemInputs(this, false);
            $(this).closest("tr").find('input[name$="[_destroy]"]').val("true");
        }
        calculateAccounting(parent, child);
    });
    $(document).on('change', 'input[name$="[amount]"]', function () {
        calculateAccounting(parent, child);
    });
};

var calculatePostTaxAmount = function (i) {
    var actualAmount = text_to_number($(i).text());
    if ($('input[name$="[sales_tax_rate]"]').size() > 0) {
        actualAmount *= (1 + text_to_number($('input[name$="[sales_tax_rate]"]').val()) / 100);
        $(i).closest("tr").find(".post-tax-actual-amount").text(number_to_currency_with_unit(actualAmount, 2, '.', ','))
    }
    $(i).closest("tr").find('input[name$="[][actual_cost]"]').val(actualAmount.toFixed(2));
};

var calculatePostTaxAmounts = function () {
    $('.purchasable-items-list div.actual-amount').each(function () {
        calculatePostTaxAmount(this);
    });
};

$(document).ready(function() {
    calculatePostTaxAmounts();
    calculatePurchasableSubTotalAndTotal();

    initAccounting("payment", "bill");
    initAccounting("receipt", "invoice");
    initAccounting("deposit", "receipt");
    initAccounting("receipt", "item");
    initAccounting("bill", "item");

    $(document).on('change', 'input[name$="[][qty]"], input[name$="[][estimated_cost]"], input[name$="[][actual_cost]"]', function () {
        calculatePurchaseAmount(this);
        calculatePurchasableSubTotalAndTotal();
    });

    $(document).on('change', '.purchasable-items-list input[name="item-chosen"]', function () {
        if ($(this).is(":checked")) {
            toggleItemInputs(this, true);
            calculatePurchaseAmount(this);
            $(this).closest("tr").find('input[name$="[][_destroy]"]').val("false");
        } else {
            toggleItemInputs(this, false);
            $(this).closest("tr").find(".actual-amount-placeholder").text("");
            $(this).closest("tr").find('input[name$="[][actual_cost]"]').val("");
            $(this).closest("tr").find('input[name$="[][_destroy]"]').val("true");
        }
        calculatePurchasableSubTotalAndTotal();
    });

    $(document).on('change', '.invoice-items-list input[name="item-chosen"]', function () {
        if ($(this).is(":checked")) {
            toggleItemInputs(this, true);
            $(this).closest("tr").find('input[name="invoice[invoices_items_attributes][][_destroy]"]').val("false");
        } else {
            toggleItemInputs(this, false);
            $(this).closest("tr").find('input[name="invoice[invoices_items_attributes][][_destroy]"]').val("true");
        }
        calculateSubTotals("invoice-amount");
        calculateTotals("invoice-amount");
    });

    $(document).on('change', '.invoice-items-list input.invoice-amount', function () {
        calculateSubTotals("invoice-amount");
        calculateTotals("invoice-amount");
    });

    $(document).on('railsAutocomplete.select', '.purchasable-items-list input[name="name[]"]', function () {
        var itemId = $('input[name="purchased_item[id]"]').val();
        var link = $("a#add-purchased-item").attr("href");
        $("a#add-purchased-item").attr("href", updateQueryStringParameter(link, "item_id", itemId));
        $("a#add-purchased-item").click();
    });

    $("#bill-form").on('railsAutocomplete.select', '.un-job-costed-item-name', function (event, data) {
        $(this).closest("tr").find("input.description").val(data.item.description);
    });

    $("#bill-form").bind('cocoon:after-remove', function () {
        calculateAccounting("bill", "item");
    });

    $("#bill-form").on('change', 'input[name="bill[job_costed]"]', function () {
        $(".job_costed").toggle();
        $(".un_job_costed").toggle();
    });

    $("#receipt-form").on('railsAutocomplete.select', '.receipt-item-name', function (event,data) {
        $(this).closest("tr").find("input.name").val(data.item.label);
        $(this).closest("tr").find("input.description").val(data.item.description);
    });
    $("#receipt-form").on('railsAutocomplete.select', '.receipt-people-name', function (event,data) {
        $(this).nextAll("input.payerId").val(data.item.id);
        $(this).nextAll("input.payerType").val(data.item.type);
    });

    $("#receipt-form").bind('cocoon:after-remove', function () {
        calculateAccounting("receipt", "item");
    });

    $("#receipt-form").on('change', 'input[name="receipt[uninvoiced]"]', function () {
        $(".invoiced").toggle();
        $(".uninvoiced").toggle();
    });

    $('#bill_project_id').on('ajax:complete', function (event, xhr, status) {
        if ($(':focus').parent().attr('id') == 's2id_bill_project_id') {
            return;
        }
        $('#bill_category_id').select2({
            width: "220px",
            placeholder: "",
            allowClear: true
        });
        $('#bill_category_id').select2('focus');

    });

    $(document).on('click', '.purchasable-items-list a.remove-item', function (e) {
        e.preventDefault();
        $(this).closest("tr").hide();
        $(this).closest("tr").find('input[name$="[][_destroy]"]').val("true");
        calculatePurchasableSubTotalAndTotal();
        return false;
    });
    $(document).on('change', 'input[name$="[shipping]"] ', function () {
        calculatePurchasableSubTotalAndTotal();
    });
    $(document).on('change', 'input[name$="[sales_tax_rate]"]', function () {
        calculatePostTaxAmounts();
        calculatePurchasableSubTotalAndTotal();
    });
})