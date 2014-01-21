$(document).ready(function () {
    if ($(".account-form").size() > 0) {
        $('.account-form input[name="account[parent_id]"]').select2({
            width: "220px",
            data: {results: JSON.parse($('.account-form input[name="account[parent_id]"]').attr("data")), text: "name"},
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