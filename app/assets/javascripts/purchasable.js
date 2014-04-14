var Purchasable = (function ($, Shared) {
    var init = function () {
        calculatePostTaxAmounts();
        calculateSubTotalAndTotal();

        $(document).on('change', 'input[name$="[][qty]"], input[name$="[][estimated_cost]"], input[name$="[][actual_cost]"]', function () {
            calculateAmount(this);
            calculateSubTotalAndTotal();
        });

        $(document).on('change', '.purchasable-items-list input[name="item-chosen"]', function () {
            if ($(this).is(":checked")) {
                Shared.toggleItemInputs(this, true);
                calculateAmount(this);
                $(this).closest("tr").find('input[name$="[][_destroy]"]').val("false");
            } else {
                Shared.toggleItemInputs(this, false);
                $(this).closest("tr").find(".actual-amount-placeholder").text("");
                $(this).closest("tr").find('input[name$="[][actual_cost]"]').val("");
                $(this).closest("tr").find('input[name$="[][_destroy]"]').val("true");
            }
            calculateSubTotalAndTotal();
        });

        $(document).on('railsAutocomplete.select', '.purchasable-items-list input[name="name[]"]', function () {
            var itemId = $('input[name="purchased_item[id]"]').val();
            var link = $("a#add-purchased-item").attr("href");
            $("a#add-purchased-item").attr("href", Shared.updateQueryStringParameter(link, "item_id", itemId));
            $("a#add-purchased-item").click();
        });

        $(document).on('click', '.purchasable-items-list a.remove-item', function (e) {
            e.preventDefault();
            $(this).closest("tr").hide();
            $(this).closest("tr").find('input[name$="[][_destroy]"]').val("true");
            calculateSubTotalAndTotal();
            return false;
        });

        $(document).on('change', 'input[name$="[shipping]"] ', function () {
            calculateSubTotalAndTotal();
        });
        $(document).on('change', 'input[name$="[sales_tax_rate]"]', function () {
            calculatePostTaxAmounts();
            calculateSubTotalAndTotal();
        });
    };

    var calculateAmount = function (obj, f) {
        var estimateCost = $(obj).closest("tr").find('input[name$="[][estimated_cost]"]');
        var qty = $(obj).closest("tr").find('input[name$="[][qty]"]');
        if (estimateCost.size() > 0 && qty.size() > 0) {
            var eValue = Shared.text_to_number($(estimateCost).val());
            var qValue = Shared.text_to_number(qty.val());
            var pValue = eValue * qValue;
            var placeHolder = $(obj).closest("tr").find(".actual-amount-placeholder");
            if (placeHolder.find(".actual-amount").size() > 0) {
                placeHolder.find(".actual-amount").html(Shared.number_to_currency_with_unit(pValue, 2, '.', ','));
            } else {
                placeHolder.prepend('<div class="actual-amount">' + Shared.number_to_currency_with_unit(pValue, 2, '.', ',') + '</div>');
            }
            calculatePostTaxAmount($(placeHolder).find(".actual-amount"));
        }
    };

    var calculateSubTotalAndTotal = function () {
        if ($("#total").size() > 0) {
            var subtotal = 0;
            var empty = true;
            $('.actual-amount:visible').each(function () {
                var value = $(this).is("input") ? $(this).val() : $(this).text();
                if (value.trim() != "" && empty) {
                    empty = false;
                }
                subtotal += Shared.text_to_number(value);
            });
            Shared.fillValue("#subtotal", subtotal, empty);
            var total = subtotal;
            if ($('input[name$="[sales_tax_rate]"]').size() > 0) {
                var salesTax = subtotal * Shared.text_to_number($('input[name$="[sales_tax_rate]"]').val()) / 100;
                $('#sales_tax').html(salesTax == 0 ? "" : Shared.number_to_currency_with_unit(salesTax, 2, '.', ','));
                total += salesTax;
                if (salesTax) {
                    empty = false;
                }
            }
            if ($('input[name$="[shipping]"]').size() > 0) {
                var shipping = Shared.text_to_number($('input[name$="[shipping]"]').val());
                total += shipping;
                if (shipping) {
                    empty = false;
                }
            }
            Shared.fillValue("#total", total, empty);
        }
    };

    var calculatePostTaxAmount = function (i) {
        var actualAmount = Shared.text_to_number($(i).text());
        if ($('input[name$="[sales_tax_rate]"]').size() > 0) {
            actualAmount *= (1 + Shared.text_to_number($('input[name$="[sales_tax_rate]"]').val()) / 100);
            $(i).closest("tr").find(".post-tax-actual-amount").html(Shared.number_to_currency_with_unit(actualAmount, 2, '.', ','))
        }
        $(i).closest("tr").find('input[name$="[][actual_cost]"]').val(actualAmount.toFixed(2));
    };

    var calculatePostTaxAmounts = function () {
        $('.purchasable-items-list div.actual-amount').each(function () {
            calculatePostTaxAmount(this);
        });
    };


    return {
        init: init,
        calculatePostTaxAmount: calculatePostTaxAmount,
        calculateSubTotalAndTotal: calculateSubTotalAndTotal
    }
})(jQuery, Shared);

