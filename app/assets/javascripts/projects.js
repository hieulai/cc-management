var Project = (function ($, Shared) {
    var init = function () {
        calculateBudgetSubtotalsAndTotals();
    };

    var calculateBudgetSubtotalAndCOAndTotal = function (s) {
        var coTotal = 0;
        var total = 0;
        var coEmpty = true;
        var allEmpty = true;
        $("tr.change_order .budget-" + s).each(function () {
            if (coEmpty && $(this).text() != "") {
                coEmpty = false;
            }
            coTotal += Shared.text_to_number($(this).text());
        });

        if (!coEmpty) {
            $(".co-budget-" + s).html(Shared.number_to_currency_with_unit(coTotal, 2, '.', ','));
        }
        $(".subtotal-budget-" + s).html(function () {
            var empty = true;
            var subtotal = 0;
            $(this).closest("tr").prevUntil("tr.category").each(function () {
                if (empty && $(this).find(".budget-" + s).text() != "") {
                    empty = false;
                }
                subtotal += Shared.text_to_number($(this).find(".budget-" + s).text());
            })
            if (!empty) {
                $(this).html(Shared.number_to_currency_with_unit(subtotal, 2, '.', ','));
                allEmpty = false;
                total += subtotal;
            }
        })
        if (!allEmpty) {
            $(".total-budget-" + s).html(Shared.number_to_currency_with_unit(total, 2, '.', ','));
        }
    };

    var calculateBudgetSubtotalsAndTotals = function () {
        if ($("#budget-form").size() > 0) {
            calculateBudgetSubtotalAndCOAndTotal("estimated-cost");
            calculateBudgetSubtotalAndCOAndTotal("committed-cost");
            calculateBudgetSubtotalAndCOAndTotal("actual-cost");
            calculateBudgetSubtotalAndCOAndTotal("estimated-profit");
            calculateBudgetSubtotalAndCOAndTotal("committed-profit");
            calculateBudgetSubtotalAndCOAndTotal("actual-profit");
        }
    };

    return {
        init: init
    }
})(jQuery, Shared);