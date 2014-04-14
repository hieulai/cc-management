var ChangeOrder = (function ($, Shared) {
    var init = function () {
        calculateCOAmounts();

        $("#item-lines").on("cocoon:before-remove", function (e, i) {
            if ($(i).hasClass("co-category")) {
                $(i).nextUntil(".co-category").remove();
            }
        });

        $("#item-lines").on("cocoon:after-remove", function (e, i) {
            Shared.calculateTotals();
        });

        $("#co-item-list").on('railsAutocomplete.select', '.co-item-name', function (event, data) {
            $(this).closest("tr").find("input.id").val(data.item.id);
            $(this).closest("tr").find("input.name").val(data.item.label);
            $(this).closest("tr").find("input.description").val(data.item.description);
            $(this).closest("tr").find("input.unit").val(data.item.unit);
            $(this).closest("tr").find("input.qty").val(data.item.qty);
            $(this).closest("tr").find("input.estimated_cost").val(data.item.estimated_cost);
            $(this).closest("tr").find("input.margin").val(data.item.margin);
            calculateCOAmount(this);
            Shared.calculateTotals();
        });

        $("#co-item-list").on('change', 'input.co-factor', function () {
            calculateCOAmount(this);
            Shared.calculateTotals();
        });
    };


    var calculateCOAmount = function (coFactor) {
        var trItem = $(coFactor).closest("tr");
        var tdQty = $(trItem).find("input.qty");
        var tdEstimatedCost = $(trItem).find("input.estimated_cost");
        var tdMargin = $(trItem).find("input.margin");
        var margin = $(tdMargin).size() > 0 ? Shared.text_to_number($(tdMargin).val()) : 0;
        var total = Shared.text_to_number($(tdQty).val()) * Shared.text_to_number($(tdEstimatedCost).val()) + margin;
        $(trItem).find("div.co-amount").html(Shared.number_to_currency_with_unit(total, 2, '.', ','));
    };

    var calculateCOAmounts = function () {
        $('input.co-factor').each(function () {
            calculateCOAmount(this);
        });
        Shared.calculateTotals();
    };

    return {
        init: init
    }
})(jQuery, Shared);