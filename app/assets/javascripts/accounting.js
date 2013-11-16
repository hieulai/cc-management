var calculatePurchaseAmount = function (obj, f){
    var estimateCost = $(obj).closest("tr").find('input[name="items[][estimated_cost]"]');
    var qty = $(obj).closest("tr").find('input[name="items[][qty]"]');
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
};

var calculatePurchasableSubTotalAndTotal = function () {
    if ($("#total").size() > 0) {
        var subtotal = 0;
        $('.actual-amount').each(function () {
            subtotal += text_to_number($(this).text());
        });
        $('#subtotal').html(subtotal == 0 ? "" : number_to_currency_with_unit(subtotal, 2, '.', ','));
        var total = subtotal;
        if ($('input[name$="[sales_tax_rate]"]').size() > 0) {
            var salesTax = subtotal * text_to_number($('input[name$="[sales_tax_rate]"]').val()) / 100;
            $('#sales_tax').html(salesTax == 0 ? "" : number_to_currency_with_unit(salesTax, 2, '.', ','));
            total += salesTax;
        }
        if ($('input[name$="[shipping]"]').size() > 0) {
            var shipping = text_to_number($('input[name$="[shipping]"]').val());
            total += shipping;
        }
        $('#total').html(total == 0 ? "" : number_to_currency_with_unit(total, 2, '.', ','));
    }
};

var calculateAccounting = function(parent, child) {
    if ($("#" + parent + "-amount").size() > 0) {
        var total = 0;
        $('input[name="' + child + '-chosen"]:checked').each(function () {
            total += text_to_number($(this).closest("tr").find('input[name="' + parent + '[' + parent + 's_' + child + 's_attributes][][amount]"]').val());
        });
        $("#" + parent + "-amount").html(total == 0 ? "" : number_to_currency_with_unit(total, 2, '.', ','));
    }
};

var initAccounting = function (parent, child) {
    calculateAccounting(parent, child);
    $(document).on('change', 'input[name="' + child + '-chosen"]', function () {
        if ($(this).is(":checked")) {
            toggleItemInputs(this, true);
            $(this).closest("tr").find('input[name="' + parent + '[' + parent + 's_' + child + 's_attributes][][_destroy]"]').val("false");
        } else {
            toggleItemInputs(this, false);
            $(this).closest("tr").find('input[name="' + parent + '[' + parent + 's_' + child + 's_attributes][][_destroy]"]').val("true");
        }
        calculateAccounting(parent, child);
    });
    $(document).on('change', 'input[name="' + parent + '[' + parent + 's_' + child + 's_attributes][][amount]"] ', function () {
        calculateAccounting(parent, child);
    });
};

var calculatePostTaxAmount = function (i) {
    var actualAmount = text_to_number($(i).text());
    if ($('input[name$="[sales_tax_rate]"]').size() > 0) {
        actualAmount *= (1 + text_to_number($('input[name$="[sales_tax_rate]"]').val()) / 100);
        $(i).closest("tr").find(".post-tax-actual-amount").text(number_to_currency_with_unit(actualAmount, 2, '.', ','))
    }
    $(i).closest("tr").find('input[name="items[][actual_cost]"]').val(actualAmount.toFixed(2));
};

var calculatePostTaxAmounts = function () {
    $('.actual-amount').each(function () {
        calculatePostTaxAmount(this);
    });
};

$(document).ready(function() {
    $("#payables .scrollable").tableScroll({height:137});
    $("#receivables .scrollable").tableScroll({height:137});

    calculatePostTaxAmounts();
    calculatePurchasableSubTotalAndTotal();

    initAccounting("payment", "bill");
    initAccounting("receipt", "invoice");
    initAccounting("deposit", "receipt");

    $(document).on('change', 'input[name="items[][qty]"], input[name="items[][estimated_cost]"]', function () {
        calculatePurchaseAmount(this);
        calculatePurchasableSubTotalAndTotal();
    });
    $(document).on('change', '.purchasable-items-list input[name="item-chosen"]', function () {
        if ($(this).is(":checked")) {
            toggleItemInputs(this, true);
            calculatePurchaseAmount(this);
        } else {
            toggleItemInputs(this, false);
            $(this).closest("tr").find(".actual-amount-placeholder").text("");
            $(this).closest("tr").find('input[name="items[][actual_cost]"]').val("");
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
    });

    $(document).on('click', '.purchasable-items-list a.remove-item', function (e) {
        e.preventDefault();
        $(this).closest("tr").remove();
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