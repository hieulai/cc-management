var Bid = (function ($, Shared) {
    var init = function () {
        calculateBidAmount();

        $(document).on('change', 'input[name="bid[bids_items_attributes][][amount]"]', function () {
            var fVal = parseFloat($(this).val());
            if (!isNaN(fVal)) {
                $(this).closest("tr").find('input[name="bid[bids_items_attributes][][_destroy]"]').val("false");
            } else {
                $(this).closest("tr").find('input[name="bid[bids_items_attributes][][_destroy]"]').val("true");
            }
            calculateBidAmount();
        });
    };

    var calculateBidAmount = function () {
        if ($('input[name="bid[bids_items_attributes][][amount]"]').size() > 0) {
            var bidAmount = 0;
            $('input[name="bid[bids_items_attributes][][amount]"]').each(function () {
                var fVal = parseFloat($(this).val());
                if (!isNaN(fVal)) {
                    bidAmount += parseFloat($(this).val());
                }
            });
            $('#bid-amount').html(Shared.number_to_currency_with_unit(bidAmount, 2, '.', ','));
        }
    };

    return {
        init: init,
        calculateBidAmount: calculateBidAmount
    }
})(jQuery, Shared);