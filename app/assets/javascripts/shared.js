var number_to_currency = function (n,c,d,t,u) {
    var n = Number(n) ,
        c = isNaN(c = Math.abs(c)) ? 2 : c,
        d = d == undefined ? "." : d,
        t = t == undefined ? "," : t,
        s = n < 0 ? "-" : "",
        i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "",
        j = (j = i.length) > 3 ? j % 3 : 0;
    if (u) {
        s += "$";
    }
    return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
}

var number_to_currency_with_unit = function (n,c,d,t) {
    return number_to_currency(n, c, d, t, true);
}

var text_to_number = function (c) {
    return Number(c.replace(/[^-0-9\.]+/g, ""));
};

/**
 * Global Total calculation based on column names
 */
function calculateTotals(s) {
    s = typeof s !== 'undefined' ? s : "";
    $("div[class^='total-" + s + "']").each(function () {
        var suffix = $(this).attr("class").substr(6);
        var amount = 0;
        var empty = true;
        $("." + suffix + ":visible").each(function () {
            var value = $(this).is("input") ? $(this).val() : $(this).text();
            if (value.trim() != "" && empty) {
                empty = false;
            }
            amount += text_to_number(value);
        });
        if (!empty) {
            $(this).text(number_to_currency_with_unit(amount, 2, '.', ','));
        } else {
            $(this).text("");
        }
    })
};

/**
 * Global Subtotal calculation based on column names
 */
function calculateSubTotals(s) {
    s = typeof s !== 'undefined' ? s : "";
    $("div[class^='subtotal-" + s + "']").each(function () {
        var trCategory = $(this).closest("tr").prevAll("tr.category").first();
        var suffix = $(this).attr("class").substr(9);
        var amount = 0;
        var empty = true;
        $("tr.item.item_" + trCategory.attr("id")).each(function () {
            var me = $(this).find("." + suffix + ":visible");
            var value = $(me).is("input") ? $(me).val() : $(me).text();
            if (value.trim() != "" && empty){
                empty = false;
            }
            amount += text_to_number(value);
        });
        if (!empty) {
            $(this).text(number_to_currency_with_unit(amount, 2, '.', ','));
        } else {
            $(this).text("");
        }
    })
};

$(document).ready(function() {
    calculateTotals();
    calculateSubTotals();
})