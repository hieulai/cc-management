var calculatePurchaseAmount = function (obj, f){
    var estimateCost = $(obj).closest("tr").find('input[name="item[][estimated_cost]"]');
    var qty = $(obj).closest("tr").find('input[name="item[][qty]"]');
    var eValue = currency_to_number($(estimateCost).val());
    var qValue = currency_to_number(qty.val());
    var pValue = eValue * qValue;
    $(obj).closest("tr").find('input[name="item[][actual_cost]"]').val(pValue);
    var placeHolder = $(obj).closest("tr").find(".actual-amount-placeholder");
    if (placeHolder.find(".actual-amount").size() > 0) {
        placeHolder.find(".actual-amount").text(number_to_currency(pValue, 2, '.', ','));
    } else {
        placeHolder.prepend('$<div class="actual-amount">' + number_to_currency(pValue, 2, '.', ',') + '</div>');
    }
};

var calculateSubTotalAndTotal = function () {
    if ($("#total").size() > 0) {
        var subtotal = 0;
        $('input[name="item[][actual_cost]"]').each(function () {
            subtotal += currency_to_number($(this).val());
        });
        $('#subtotal').html(subtotal == 0 ? "" : "$" + number_to_currency(subtotal, 2, '.', ','));
        var salesTax = currency_to_number($('input[name="purchase_order[sales_tax]"]').val());
        var shipping = currency_to_number($('input[name="purchase_order[shipping]"]').val());
        var total = subtotal + salesTax + shipping;
        $('#total').html(total == 0 ? "" : "$" + number_to_currency(total, 2, '.', ','));
    }
};

var toggleItemInputs = function (checbox, s) {
    $(checbox).closest("tr").find('.text-field').toggle(s);
    $(checbox).closest("tr").find('.value-field').toggle(!s);
};

$(document).ready(function() {
    calculateSubTotalAndTotal();
    $(document).on('change', 'input[name="item[][qty]"], input[name="item[][estimated_cost]"]', function () {
        var chosen =  $(this).closest("tr").find('input[name="item-chosen"]');
        if ($(chosen).is(":checked")) {
            calculatePurchaseAmount(this);
            calculateSubTotalAndTotal();
        }
    });
    $(document).on('change', 'input[name="item-chosen"]', function () {
        if ($(this).is(":checked")) {
            toggleItemInputs(this, true);
            calculatePurchaseAmount(this);
        } else {
            toggleItemInputs(this, false);
            $(this).closest("tr").find(".actual-amount-placeholder").text("");
            $(this).closest("tr").find('input[name="item[][actual_cost]"]').val("");
        }
        calculateSubTotalAndTotal();
    });
    $(document).on('change', 'input[name="purchase_order[sales_tax]"], input[name="purchase_order[shipping]"] ', function () {
        calculateSubTotalAndTotal();
    });
})