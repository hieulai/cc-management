$(document).ready(function () {
    $(".editable").editable({
        mode: 'inline',
        ajaxOptions: {
            type: 'PUT',
            dataType: 'json'
        },
        success: function(response, newValue) {
            if(!response.errors){
                if ($(this).data("resource")=="item"){
                    $(this).closest("tr").find("td.price").html("$" + response.price);
                }
            }
        }
    });
})