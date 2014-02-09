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

var bounceEffectRight = function(element){
  element.effect("bounce", {
    direction: "right",
    distance: 15,
    times: 4
  }, 1000);
  element.focus();
  return false;
}

var remove_fields = function(link){
	$(link).prev("input[type=hidden]").val("1");
	$(link).closest('.fields').hide();
}

var add_fields = function(link, association, content){
	var new_id = new Date().getTime();
	var regexp = new RegExp("new_" + association, "g")
	$(link).parent().before(content.replace(regexp, new_id));
}

var load_add_link = function(){
    if ((addTaskLink = $(".cocoon-container").find("#add_item:hidden")) && ($(".cocoon-container .nested-fields:visible").size() == 0)) {
        addTaskLink.data("association-insertion-node", 'this')
            .data("association-insertion-method", 'before')
            .show()
    }
}

var updateQueryStringParameter = function (uri, key, value) {
    var re = new RegExp("([?|&])" + key + "=.*?(&|$)", "i");
    separator = uri.indexOf('?') !== -1 ? "&" : "?";
    if (uri.match(re)) {
        return uri.replace(re, '$1' + key + "=" + value + '$2');
    }
    else {
        return uri + separator + key + "=" + value;
    }
}

var toggleItemInputs = function (checbox, s) {
    $(checbox).closest("tr").find('.text-field').toggle(s);
    $(checbox).closest("tr").find('.value-field').toggle(!s);
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
        $("select").select2({
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
            altField: "#" + $(this).closest(".controls").find('input[type="hidden"]').attr("id"),
            altFormat: "yy-mm-dd",
            dateFormat: "mm-dd-yy"
        });
    });
};

var transformToDateRangePickerFor = function (element) {
    if (!element) {
        element = document;
    }
    $(element).find(".daterangepicker").each(function () {
        var $fromDate = $(this).find(".from_date");
        var $toDate = $(this).find(".to_date");
        $fromDate.datepicker({
            altField: "#" + $fromDate.closest(".controls").find('input[type="hidden"]').attr("id"),
            altFormat: "yy-mm-dd",
            dateFormat: "mm-dd-yy",
            onClose: function (selectedDate) {
                $(this).closest(".daterangepicker").find(".to_date").datepicker("option", "minDate", selectedDate);
            }
        });
        $toDate.datepicker({
            altField: "#" + $toDate.closest(".controls").find('input[type="hidden"]').attr("id"),
            altFormat: "yy-mm-dd",
            dateFormat: "mm-dd-yy",
            onClose: function (selectedDate) {
                $(this).closest(".daterangepicker").find(".from_date").datepicker("option", "maxDate", selectedDate);
            }
        });

        $(this).on('change', '.range-picker', function () {
            var $fromDate = $(this).closest(".daterangepicker").find(".from_date");
            var $toDate = $(this).closest(".daterangepicker").find(".to_date");
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

$(document).ready(function() {
    load_add_link();
    $("select").select2({
        width: "220px",
        placeholder: "",
        allowClear: true
    });

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
          load_add_link();
    });
    $( "#tasksContainer" ).sortable({
        revert: true
    });
    $( "#tasksContainer" ).disableSelection();
    $('.tasklist').submit(function(){
      $(".task").each(function(){
          $(this).find(".position").val($(this).offset().top);
      })
    });
    $(document).on('click', 'input[type="submit"]', function(){
        var $form = $($(this).data("form"));
        if ($(this).data("original-url")) {
            $form.attr("action", updateQueryStringParameter($form.attr("action"), "original_url", $(this).data("original-url")));
        }
        $form.submit();
    })

    $(document).on('click', 'tr.clickable', function () {
        var href = $(this).find("a.clickable-link").attr("href");
        if (href) {
            window.location = href;
        }
    });

    $(document).on('click', '.action-container, .action-container input[type="checkbox"]', function (e) {
        e.stopPropagation();
    });

    $(document).on('change', 'input[type="checkbox"].toggle', function () {
        $($(this).attr("target")).toggle();
    });

    $(".data-tables").each(function () {
        var options = {
            "bPaginate": false,
            "bLengthChange": false,
            "bFilter": true,
            "bSort": true,
            "bInfo": false,
            "bAutoWidth": false,
            "aaSorting": [
                [ 0, "desc" ]
            ]
        }
        var oTable = $(this).dataTable(options);
        $("#" + $(this).attr("id") + "_wrapper").prev(".button-group").appendTo("#" + $(this).attr("id") + "_filter");
        if ($(this).attr("id") == "bill-list") {
            $('input[type="radio"][name="bills_type"]').change(function () {
                var val = $(this).val() == "All" ? "" : $(this).val();
                oTable.fnFilter(val, 8, false, true, true, false);
            });
        }
    });

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
    transformToDatePickerFor();
    transformToSelect2For();
    transformToDateRangePickerFor();

})