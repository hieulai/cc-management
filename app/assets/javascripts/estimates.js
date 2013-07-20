$(document).ready(function () {
    $("body").editable({
        selector: '.editable',
        mode: 'inline',
        ajaxOptions: {
            type: 'PUT',
            dataType: 'json'
        },
        success: function(response, newValue) {
            if(!response.errors){
                if ($(this).data("resource")=="item"){
                    $(this).closest("tr").find("td.price").html("$" + response.price);
                    $(this).closest("tr").find("td.amount").html("$" + response.amount);
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
})