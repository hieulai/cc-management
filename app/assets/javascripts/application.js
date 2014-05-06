// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require moment
//= require cocoon
//= require autocomplete-rails
//= require bootstrap-modal
//= require jquery.dataTables
//= require jquery.dataTables.extends
//= require shared
//= require responsive-tables
//= require select2
//= require_tree .
//= stub wkhtmltopdf_tableSplitHack

var Application = (function ($) {

    var init = function(){
        loadAddLink();
        loadDataTables();
        loadInstructions();
        transformToDatePickerFor();
        transformToSelect2For();
        transformToDateRangePickerFor();
        setupAjaxBehavior();
        setupCheckboxBehavior();
        setupTrClickable();
        setupFormSubmit();
        setupCocoonBehavior();
    };

    var loadAddLink = function(){
        if ((addTaskLink = $(".cocoon-container").find("#add_item:hidden")) && ($(".cocoon-container .nested-fields:visible").size() == 0)) {
            addTaskLink.data("association-insertion-node", 'this')
                .data("association-insertion-method", 'before')
                .show()
        }
    };

    var transformToSelect2For = function (element) {
        if (!element) {
            element = document;
        }
        $(element).find("input.to_select2").each(function () {
            $(this).select2({
                width: "220px",
                data: {results: JSON.parse($(this).attr("data-source")), text: "name"},
                placeholder: "",
                allowClear: true,
                formatSelection: function (item) {
                    return item.name
                },
                formatResult: function (item) {
                    return item.name
                }
            });
        });
        $(element).find("select").each(function () {
            if ($(this).attr('id') && $('#s2id_' + $(this).attr('id')).length > 0) {
                return;
            }
            $(this).select2({
                width: "220px",
                placeholder: "",
                allowClear: true
            });
        });
    };

    var transformToDatePickerFor = function (element) {
        if (!element) {
            element = document;
        }
        $(element).find(".datepicker").each(function () {
            $(this).datepicker({
                altField: "#" + $(this).next('input[type="hidden"]').attr("id"),
                altFormat: "yy-mm-dd",
                dateFormat: "mm-dd-yy"
            });
        });
    };

    var transformToDateRangePickerFor = function (element) {
        if (!element) {
            element = document;
        }
        $(element).find(".daterangepickerSet").each(function () {
            var $fromDate = $(this).find(".from_date");
            var $toDate = $(this).find(".to_date");
            $fromDate.datepicker({
                altField: "#" + $fromDate.next('input[type="hidden"]').attr("id"),
                altFormat: "yy-mm-dd",
                dateFormat: "mm-dd-yy",
                onClose: function (selectedDate) {
                    $(this).closest(".daterangepickerSet").find(".to_date").datepicker("option", "minDate", selectedDate);
                }
            });
            $toDate.datepicker({
                altField: "#" + $toDate.next('input[type="hidden"]').attr("id"),
                altFormat: "yy-mm-dd",
                dateFormat: "mm-dd-yy",
                onClose: function (selectedDate) {
                    $(this).closest(".daterangepickerSet").find(".from_date").datepicker("option", "maxDate", selectedDate);
                }
            });

            $(this).on('change', '.range-picker', function () {
                var $fromDate = $(this).closest(".daterangepickerSet").find(".from_date");
                var $toDate = $(this).closest(".daterangepickerSet").find(".to_date");
                switch ($(this).val()) {
                    case "current_month":
                        $fromDate.datepicker("setDate", moment().startOf('month').toDate());
                        $toDate.datepicker("setDate", moment().endOf('month').toDate());
                        break;
                    case "current_quarter":
                        var quarterAdjustment = moment().month() % 3;
                        var quarterStartDate = moment().subtract({ months: quarterAdjustment }).startOf('month');
                        var quarterEndDate = quarterStartDate.clone().add({ months: 2 }).endOf('month');
                        $fromDate.datepicker("setDate", quarterStartDate.toDate());
                        $toDate.datepicker("setDate", quarterEndDate.toDate());
                        break;
                    case "current_year":
                        $fromDate.datepicker("setDate", moment().startOf('year').toDate());
                        $toDate.datepicker("setDate", moment().endOf('year').toDate());
                        break;
                    default :
                        $fromDate.datepicker("setDate", null);
                        $toDate.datepicker("setDate", null);
                }
            });

        });
    };

    var loadInstructions = function(){
        $(".instructions").hide();
        $(".trigger").click(function () {
            if ($(".instructions").is(":hidden")) {
                $(".instructions").slideDown("slow");
            }
            else {
                $(".instructions").hide();
            }
        });
    };

    var setupCocoonBehavior = function(){
        $(document).on('click', '.trigger_add', function(){
            var container = $(this).closest(".cocoon-container");
            container.find("#add_item").data("association-insertion-node", '#' + $(this).closest(".nested-fields")[0].id)
                .data("association-insertion-method", 'after')
                .click();
        });

        $(document).bind('cocoon:after-insert', function (e, added_object) {
            transformToSelect2For(added_object);
        });

        $('.cocoon-container').bind('cocoon:after-insert', function (e, task_to_be_added) {
            if (addTaskLink = $("#add_item:visible")){
                addTaskLink.hide()
            }
            task_to_be_added.attr('id', 'item_' + new Date().getMilliseconds());
        });

        $('.cocoon-container').bind('cocoon:after-remove', function() {
            loadAddLink();
        });
    };

    var loadDataTables = function () {
        $(".data-tables").each(function () {
            var oTable = $(this).dataTable({
                "bPaginate": false,
                "bLengthChange": false,
                "bFilter": false,
                "bSort": true,
                "bInfo": false,
                "bAutoWidth": false,
                "aaSorting": [
                    [ 0, "desc" ]
                ]
            });
        });
    };

    var setupAjaxBehavior = function(){
        $(document).ajaxStart(function () {
            $(".loader").show();
            $('input[type="submit"]').attr('disabled', true);
        });

        $(document).ajaxStop(function () {
            $(".loader").hide();
            $('input[type="submit"]').removeAttr('disabled');
            transformToDatePickerFor();
            transformToSelect2For();
            transformToDateRangePickerFor();
        });
    };

    var setupCheckboxBehavior = function(){
        $(document).on('click', '.action-container, .action-container input[type="checkbox"]', function (e) {
            e.stopPropagation();
        });

        $(document).on('change', 'input[type="checkbox"].toggle', function () {
            $($(this).attr("target")).toggle();
        });
    };

    var setupTrClickable = function(){
        $(document).on('click', 'tr.clickable', function () {
            var href = $(this).find("a.clickable-link").attr("href");
            if (href) {
                window.location = href;
            }
        })
    };

    var setupFormSubmit = function(){
        $(document).on('click', 'input[type="submit"]', function(){
            var $form = $($(this).data("form"));
            if ($(this).data("original-url")) {
                $form.attr("action", Shared.updateQueryStringParameter($form.attr("action"), "original_url", $(this).data("original-url")));
            }
            $form.submit();
        })
    };

    return {
        init: init,
        transformToDatePickerFor: transformToDatePickerFor
    }
})(jQuery);

$(document).ready(function() {
    Application.init();
})