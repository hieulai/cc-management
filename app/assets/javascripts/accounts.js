$(document).ready(function () {
    if ($("#new_account").size() > 0) {
        $('#new_account input[name="account[parent_id]"]').select2({
            width: "220px",
            data: {results: JSON.parse($('#new_account input[name="account[parent_id]"]').attr("data")), text: "name"},
            placeholder: "",
            allowClear: true,
            formatSelection: function (item) {
                return item.name
            },
            formatResult: function (item) {
                return item.name
            }
        });
    }
});