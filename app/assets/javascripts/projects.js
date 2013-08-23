function calculateBidAmount() {
    var bidAmount = 0;
    $('input[name="item[][uncommitted_cost]"').each(function () {
        var fVal = parseFloat($(this).val());
        if (!isNaN(fVal)){
            bidAmount += parseFloat($(this).val());
        }
    });
    $('#bid-amount').text("$" + bidAmount.toFixed(2));
}
$(document).ready(function () {
    $(document).on('change', 'input[name="item[][uncommitted_cost]"]', function () {
        calculateBidAmount();
    });
    if ($('input[name="item[][uncommitted_cost]').size() >0) {
        calculateBidAmount();
    }
})