function calculateBidAmount() {
    var bidAmount = 0;
    $('input[name="item[][uncommitted_cost]"]').each(function () {
        var fVal = parseFloat($(this).val());
        if (!isNaN(fVal)){
            bidAmount += parseFloat($(this).val());
        }
    });
    $('#bid-amount').text(number_to_currency_with_unit(bidAmount, 2, '.', ','));
}

function calculateBudgetSubtotalAndTotal(s) {
    var total = 0;
    var empty = true;
    $(".subtotal-budget-" + s).each(function () {
        var subtotal = 0;
        $(this).closest("tr").prevUntil("tr.category").each(function () {
            if (empty && $(this).find(".budget-" + s).text() != "") {
                empty = false;
            }
            subtotal += text_to_number($(this).find(".budget-" + s).text());
        })
        if (!empty) {
            $(this).text(number_to_currency(subtotal, 2, '.', ','))
        }
        total += subtotal;
    })
    if (!empty) {
        $(".total-budget-" + s).text(number_to_currency(total, 2, '.', ','));
    }
}

function calculateBudgetSubtotalsAndTotals(){
    if ("#budget-form") {
        calculateBudgetSubtotalAndTotal("estimated-cost");
        calculateBudgetSubtotalAndTotal("committed-cost");
        calculateBudgetSubtotalAndTotal("actual-cost");
        calculateBudgetSubtotalAndTotal("estimated-profit");
        calculateBudgetSubtotalAndTotal("committed-profit");
        calculateBudgetSubtotalAndTotal("actual-profit");
    }
}
$(document).ready(function () {
    calculateBudgetSubtotalsAndTotals();
    $(document).on('change', 'input[name="item[][uncommitted_cost]"]', function () {
        calculateBidAmount();
    });
    if ($('input[name="item[][uncommitted_cost]"]').size() >0) {
        calculateBidAmount();
    }
})