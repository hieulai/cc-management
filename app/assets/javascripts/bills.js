//= require purchasable

var Bill = (function ($, Shared, Accounting, Purchasable) {
    var init = function () {
        Accounting.init("bill", "item");
        Purchasable.init();

        $("#bill-form").on('railsAutocomplete.select', '.un-job-costed-item-name', function (event, data) {
            $(this).closest("tr").find("input.description").val(data.item.description);
        });

        $("#bill-form").bind('cocoon:after-remove', function () {
            Accounting.calculate("bill", "item");
        });

        $("#bill-form").on('change', 'input[name="bill[job_costed]"]', function () {
            $(".job_costed").toggle();
            $(".un_job_costed").toggle();
        });
    };

    return {
        init: init
    }
})(jQuery, Shared, Accounting, Purchasable);