var Estimate = (function ($, Shared) {
    var init = function () {
        $("body").editable({
            selector: '.editable',
            mode: 'inline',
            ajaxOptions: {
                type: 'PUT',
                dataType: 'json'
            },
            success: function (response, newValue) {
                if ($(this).data("resource") == "item") {
                    var trItem = $(this).closest("tr");
                    if (response.margin == null) {
                        response.margin = 0;
                    }
                    if (response.markup == null) {
                        trItem.find("td .markup").parent().text("");
                    }
                    trItem.find("td .price").html(Shared.number_to_currency(response.price, 2, '.', ','));
                    trItem.find("td .margin a").text(Shared.number_to_currency(response.margin, 2, '.', ','));
                    trItem.find("td .amount").html(Shared.number_to_currency(response.amount, 2, '.', ','));
                    Shared.calculateSubTotals();
                    Shared.calculateTotals();
                } else if ($(this).data("resource") == "category") {
                    $(this).closest("tr.category").nextAll("tr.subtotal").first().find(".category-name").text(newValue);
                }
            },
            error: function (response, newValue) {
                var errors = $.parseJSON(response.responseText).errors;
                $.rails.createConfirmDialog('Information', errors, true);
            }
        });

        $(document).off('click', '.trigger-add').on('click', '.trigger-add', function () {
            var row = $(this).closest("tr");
            row.nextAll("tr.add").first().clone().addClass("temp").show().insertAfter(row);
            return false;
        });
        $(document).off('click', '.cancel-add').on('click', '.cancel-add', function () {
            var row = $(this).closest("tr").first();
            if (row.hasClass("temp")) {
                row.remove();
            } else {
                row.hide();
            }
            return false;
        });

        if ($("input#estimate_profit").size() > 0) {
            $("input#estimate_profit").off('change').on('change', function () {
                Shared.calculateTotals("margin");
                Shared.calculateTotals("price");
            });
        }
    };

    return {
        init: init
    }
})(jQuery, Shared);