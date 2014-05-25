var Invoice = (function ($, moment ,  Shared, Accounting) {
    var init = function () {

        $(document).on('change', '.invoiceables-list input.invoice-amount', function () {
            Shared.calculateSubTotals("invoice-amount");
            Shared.calculateTotals("invoice-amount");
        });

        $(document).on('change', '.invoiceables-list input.chosen', function () {
            if ($(this).is(":checked")) {
                Shared.toggleItemInputs(this, true);
                $(this).closest("tr").find('input.destroy').val("false");
            } else {
                Shared.toggleItemInputs(this, false);
                $(this).closest("tr").find('input.destroy').val("true");
            }
            Shared.calculateSubTotals("invoice-amount");
            Shared.calculateTotals("invoice-amount");
        });

        $(document).on('change', '#invoice_estimate_id', function () {
            var $link = $("#hidden_estimate_link");
            var url = $link.attr("href");
            url = Shared.updateQueryStringParameter(url, "invoice[estimate_id]", $(this).val());
            $link.attr("href", url);
            clearDateRangePicker();
            triggerEstimateSelection("", "");
        });

        initDateRangePicker();
    };

    var triggerEstimateSelection = function (from_date, to_date) {
        var $link = $("#hidden_estimate_link");
        var url = $link.attr("href");
        url = Shared.updateQueryStringParameter(url, "from_date", from_date);
        url = Shared.updateQueryStringParameter(url, "to_date", to_date);
        $link.attr("href", url);
        $link.click();
    };

    var initDateRangePicker = function () {
        var $fromDateInput = $("#invoice_bill_from_date");
        var $toDateInput = $("#invoice_bill_to_date");
        var options = {
            format: 'MM-DD-YYYY',
            locale: { cancelLabel: 'Clear' },
            separator: " to "
        }
        if ($fromDateInput.val().length && $toDateInput.val().length) {
            options.startDate = $fromDateInput.val();
            options.endDate = $toDateInput.val();
            $('#reservation').val($fromDateInput.val() + options.separator + $toDateInput.val());
        }

        $('#reservation').daterangepicker(
            options, function (start, end, label) {
                var fromDate = start.format('YYYY-MM-DD');
                var toDate = end.format('YYYY-MM-DD');
                if (fromDate == "Invalid date" || toDate == "Invalid date" ) {
                    return;
                }
                $fromDateInput.val(fromDate);
                $toDateInput.val(toDate);
                triggerEstimateSelection(fromDate, toDate);
            }
        );
        $('#reservation').on('cancel.daterangepicker', function (ev, picker) {
            clearDateRangePicker();
            triggerEstimateSelection("", "");
        });
    };

    var clearDateRangePicker = function(){
        var $me = $('#reservation');
        $me.val('');
        $me.data('daterangepicker').setStartDate(moment().startOf('day'));
        $me.data('daterangepicker').setEndDate(moment().endOf('day'));
    }

    return {
        init: init
    }
})(jQuery, window.moment, Shared, Accounting);