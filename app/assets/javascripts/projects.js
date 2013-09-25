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

function calculateBudgetSubtotalAndCOAndTotal(s) {
    var coTotal = 0;
    var total = 0;
    var coEmpty = true;
    var allEmpty = true;
    $("tr.change_order .budget-" + s).each(function() {
        if (coEmpty && $(this).text() != "") {
            coEmpty = false;
        }
        coTotal+= text_to_number($(this).text());
    })
    if (!coEmpty) {
        $(".co-budget-" + s).text(number_to_currency_with_unit(coTotal, 2, '.', ','));
    }
    $(".subtotal-budget-" + s).each(function () {
        var empty = true;
        var subtotal = 0;
        $(this).closest("tr").prevUntil("tr.category").each(function () {
            if (empty && $(this).find(".budget-" + s).text() != "") {
                empty = false;
            }
            subtotal += text_to_number($(this).find(".budget-" + s).text());
        })
        if (!empty) {
            $(this).text(number_to_currency_with_unit(subtotal, 2, '.', ','));
            allEmpty = false;
            total += subtotal;
        }
    })
    if (!allEmpty) {
        $(".total-budget-" + s).text(number_to_currency_with_unit(total, 2, '.', ','));
    }
}

function calculateBudgetSubtotalsAndTotals(){
    if ($("#budget-form").size() > 0) {
        calculateBudgetSubtotalAndCOAndTotal("estimated-cost");
        calculateBudgetSubtotalAndCOAndTotal("committed-cost");
        calculateBudgetSubtotalAndCOAndTotal("actual-cost");
        calculateBudgetSubtotalAndCOAndTotal("estimated-profit");
        calculateBudgetSubtotalAndCOAndTotal("committed-profit");
        calculateBudgetSubtotalAndCOAndTotal("actual-profit");
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

    $("#item-lines").on("cocoon:before-remove", function(e, i) {
        if ($(i).hasClass("co-category")) {
            $(i).nextUntil(".co-category").remove();
        }
    })

    $(document).on('change', ".change-order-items", function () {
        var me = this;
        $.get($(this).attr("data-select-url") + "/a.json", {"item[id]": $(this).val()})
            .done(function (data) {
                $(me).closest("tr").find("input.name").val(data.name);
                $(me).closest("tr").find("input.description").val(data.description);
                $(me).closest("tr").find("input.unit").val(data.unit);
                $(me).closest("tr").find("input.qty").val(data.qty);
                $(me).closest("tr").find("input.estimated_cost").val(data.estimated_cost);
                $(me).closest("tr").find("input.margin").val(data.margin);
            });
    });
})