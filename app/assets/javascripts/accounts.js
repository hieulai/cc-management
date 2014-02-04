$(document).ready(function() {
    $(".account-form").on('focus', 'input[name="account[opening_balance]"]', function () {
        $(this).next().show();
    });
});