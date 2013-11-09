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

function calculateCOAmount(coFactor){
    var trItem = $(coFactor).closest("tr");
    var tdQty = $(trItem).find("input.qty");
    var tdEstimatedCost = $(trItem).find("input.estimated_cost");
    var tdMargin = $(trItem).find("input.margin");
    var total = text_to_number($(tdQty).val()) * text_to_number($(tdEstimatedCost).val()) + text_to_number($(tdMargin).val());
    $(trItem).find("div.co-amount").text(number_to_currency_with_unit(total, 2, '.', ','))
}

function calculateCOAmounts() {
    $('input.co-factor').each(function () {
        calculateCOAmount(this);
    });
    calculateTotals();
};

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
    calculateCOAmounts();

    $(document).on('change', 'input[name="item[][uncommitted_cost]"]', function () {
        calculateBidAmount();
    });
    if ($('input[name="item[][uncommitted_cost]"]').size() >0) {
        calculateBidAmount();
    }

    $("#item-lines").on("cocoon:after-remove", function(e, i) {
        if ($(i).hasClass("co-category")) {
            $(i).nextUntil(".co-category").remove();
        }
        calculateTotals();
    })

    $("#co-item-list").on('railsAutocomplete.select', '.co-item-name', function (event,data) {
        $(this).closest("tr").find("input.id").val(data.item.id);
        $(this).closest("tr").find("input.name").val(data.item.label);
        $(this).closest("tr").find("input.description").val(data.item.description);
        $(this).closest("tr").find("input.unit").val(data.item.unit);
        $(this).closest("tr").find("input.qty").val(data.item.qty);
        $(this).closest("tr").find("input.estimated_cost").val(data.item.estimated_cost);
        $(this).closest("tr").find("input.margin").val(data.item.margin);
        calculateCOAmount(this);
        calculateTotals();
    });

    $("#co-item-list").on('change', 'input.co-factor', function () {
        calculateCOAmount(this);
        calculateTotals();
    });

    $('.edit_bid').on('change','input[name="bid[chosen]"]', function () {
        $('.edit_bid').find('.due-date-inputs').toggle();
    });
})