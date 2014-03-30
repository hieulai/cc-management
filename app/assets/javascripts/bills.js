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

        $('#bill_project_id').on('ajax:complete', function (event, xhr, status) {
            if ($(':focus').parent().attr('id') == 's2id_bill_project_id') {
                return;
            }
            $('#bill_category_id').select2({
                width: "220px",
                placeholder: "",
                allowClear: true
            });
            $('#bill_category_id').select2('focus');

        });
    };

    return {
        init: init
    }
})(jQuery, Shared, Accounting, Purchasable);