var calculatePurchaseAmount = function (obj, f){
    var estimateCost = $(obj).closest("tr").find('input[name="items[][estimated_cost]"]');
    var qty = $(obj).closest("tr").find('input[name="items[][qty]"]');
    var eValue = currency_to_number($(estimateCost).val());
    var qValue = currency_to_number(qty.val());
    var pValue = eValue * qValue;
    $(obj).closest("tr").find('input[name="items[][actual_cost]"]').val(pValue);
    var placeHolder = $(obj).closest("tr").find(".actual-amount-placeholder");
    if (placeHolder.find(".actual-amount").size() > 0) {
        placeHolder.find(".actual-amount").text(number_to_currency_with_unit(pValue, 2, '.', ','));
    } else {
        placeHolder.prepend('$<div class="actual-amount">' + number_to_currency_with_unit(pValue, 2, '.', ',') + '</div>');
    }
};

var calculateSubTotalAndTotal = function () {
    if ($("#total").size() > 0) {
        var subtotal = 0;
        $('input[name="items[][actual_cost]"]').each(function () {
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
    $(document).on('change', 'input[name="items[][qty]"], input[name="items[][estimated_cost]"]', function () {
        calculatePurchaseAmount(this);
        calculateSubTotalAndTotal();
    });
    $(document).on('change', 'input[name="item-chosen"]', function () {
        if ($(this).is(":checked")) {
            toggleItemInputs(this, true);
            calculatePurchaseAmount(this);
        } else {
            toggleItemInputs(this, false);
            $(this).closest("tr").find(".actual-amount-placeholder").text("");
            $(this).closest("tr").find('input[name="items[][actual_cost]"]').val("");
        }
        calculateSubTotalAndTotal();
    });
    $(document).on('change', "select#purchased_item_id", function () {
        var link = $("a#add-purchased-item").attr("href");
        $("a#add-purchased-item").attr("href", updateQueryStringParameter(link, "item_id", $(this).val()));
    });
    $(document).on('click', '.purchase-orders-list a.remove-item', function (e) {
        e.preventDefault();
        $(this).closest("tr").remove();
        calculateSubTotalAndTotal();
        return false;
    });
    $(document).on('change', 'input[name="purchase_order[sales_tax]"], input[name="purchase_order[shipping]"] ', function () {
        calculateSubTotalAndTotal();
    });
})