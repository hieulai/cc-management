$(document).ready(function() {
    $(".account-form").on('change', 'input[name="account[opening_balance]"]', function () {
        $(this).next().show();
    });
});