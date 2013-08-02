function calculateSubTotals(trCategory) {
    if (trCategory != null) {
        var trSubtotal = trCategory.nextAll("tr.subtotal").first();
        var amount = 0;
        var margin = 0
        var price = 0;
        $("tr.item.item_" + trCategory.attr("id")).each(function () {
            amount += parseFloat($(this).find(".amount").text());
            margin += parseFloat($(this).find(".margin").text());
            price += parseFloat($(this).find(".price").text());
        });
        trSubtotal.find(".subtotal-amount").text(amount);
        trSubtotal.find(".subtotal-margin").text(margin);
        trSubtotal.find(".subtotal-price").text(price);
    }
};

function calculateTotals() {
    var amount = 0;
    var margin = 0
    var price = 0;
    $("tr.item").each(function () {
        amount += parseFloat($(this).find(".amount").text());
        margin += parseFloat($(this).find(".margin").text());
        price += parseFloat($(this).find(".price").text());
    });
    $("div.total-amount").text(amount);
    $("div.total-margin").text(margin);
    $("div.total-price").text(price);
    $("input.total-amount").val(amount);
    $("input.total-margin").val(margin);
    $("input.total-price").val(price);
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
                    trItem.find("td .price").html(response.price);
                    trItem.find("td .margin a").text(response.margin);
                    trItem.find("td .amount").html(response.amount);
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
    $(document).on('click', 'input[type="submit"]', function(){
        $($(this).data("form")).submit();
    })
})