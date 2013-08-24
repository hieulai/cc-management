function calculateSubTotals(trCategory) {
    if (trCategory != null) {
        var trSubtotal = trCategory.nextAll("tr.subtotal").first();
        var amount = 0;
        var margin = 0
        var price = 0;
        $("tr.item.item_" + trCategory.attr("id")).each(function () {
            amount += currency_to_number($(this).find(".amount").text());
            margin += currency_to_number($(this).find(".margin").text());
            price += currency_to_number($(this).find(".price").text());
        });
        trSubtotal.find(".subtotal-amount").text(number_to_currency(amount, 2, '.', ','));
        trSubtotal.find(".subtotal-margin").text(number_to_currency(margin, 2, '.', ','));
        trSubtotal.find(".subtotal-price").text(number_to_currency(price, 2, '.', ','));
    }
};

function calculateTotals() {
    var amount = 0;
    var margin = 0
    var price = 0;
    $("tr.item").each(function () {
        amount += currency_to_number($(this).find(".amount").text());
        margin += currency_to_number($(this).find(".margin").text());
        price += currency_to_number($(this).find(".price").text());
    });
    $("div.total-amount").text(number_to_currency(amount, 2, '.', ','));
    $("div.total-margin").text(number_to_currency(margin, 2, '.', ','));
    $("div.total-price").text(number_to_currency(price, 2, '.', ','));
    $("input.total-amount").val(number_to_currency(amount, 2, '.', ','));
    $("input.total-margin").val(number_to_currency(margin, 2, '.', ','));
    $("input.total-price").val(number_to_currency(price, 2, '.', ','));
};

$(document).ready(function () {
    $("body").editable({
        selector: '.editable',
        mode: 'inline',
        ajaxOptions: {
            type: 'PUT',
            dataType: 'json'
        },
        success: function (response, newValue) {
            if (!response.errors) {
                if ($(this).data("resource") == "item") {
                    var trItem = $(this).closest("tr");
                    if (response.margin == null) {
                        response.margin = 0;
                    }
                    trItem.find("td .price").html(number_to_currency(response.price, 2, '.', ','));
                    trItem.find("td .margin a").text(number_to_currency(response.margin, 2, '.', ','));
                    trItem.find("td .amount").html(number_to_currency(response.amount, 2, '.', ','));
                    calculateSubTotals(trItem.prevAll("tr.category").first());
                    calculateTotals();
                } else if ($(this).data("resource") == "category") {
                    $(this).closest("tr.category").nextAll("tr.subtotal").first().find(".category-name").text(newValue);
                }
            }
        }
    });

    $(document).on('click', '.trigger-add', function () {
        var row = $(this).closest("tr");
        row.nextAll("tr.add").first().clone().addClass("temp").show().insertAfter(row);
        return false;
    });
    $(document).on('click', '.cancel-add', function () {
        var row = $(this).closest("tr").first();
        if (row.hasClass("temp")) {
            row.remove();
        } else {
            row.hide();
        }
        return false;
    });
    calculateTotals();
})