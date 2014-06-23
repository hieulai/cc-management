var Accounting = (function ($, Shared) {
    var init = function (parent, child) {
        calculate(parent, child);

        $(document).on('change', 'input[name="' + child + '-chosen"]', function () {
            if ($(this).is(":checked")) {
                Shared.toggleItemInputs(this, true);
                $(this).closest("tr").find('input[name$="[_destroy]"]').val("false");
            } else {
                Shared.toggleItemInputs(this, false);
                $(this).closest("tr").find('input[name$="[_destroy]"]').val("true");
            }
            calculate(parent, child);
        });

        $(document).on('change', 'input[name$="[amount]"]', function () {
            calculate(parent, child);
        });
    };

    var initAccounts = function () {
        $('tr.clickable').first().click();
        $(document).on('ajax:beforeSend', 'a.expander', function (event) {
            $(this).removeClass("collapsed").addClass("expanded");
            $(this).on('click', function () {
                return false;
            });
        });
        $(document).on('ajax:success', 'a.expander', function (event) {

            $(this).on('click', function () {
                $(this).toggleClass("collapsed expanded");
                $(this).closest("tr").nextUntil("tr.person").toggle();
                return false;
            });
        });

        $(window).resize(function () {
            $('.full-height').each(function () {
                var divTop = $(this).offset().top;
                var winHeight = $(window).height();
                var divHeight = winHeight - divTop;
                $(this).height(divHeight);
                $(this).css("overflow", "scroll");
            })
        });
        $(window).trigger('resize');

        var min = $('#sidebar').width();
        $('#dragbar').mousedown(function (e) {
            e.preventDefault();
            $(document).mousemove(function (e) {
                e.preventDefault();
                var x = e.pageX - $('#sidebar').offset().left;
                if (x > min) {
                    $('#sidebar').css("width", x);
                    $('#details').css("width", $(window).width() - x - $('#dragbar').width());
                }
            })
        });
        $(document).mouseup(function (e) {
            $(document).unbind('mousemove');
        });
    };

    var calculate = function (parent, child) {
        if ($("." + parent + "-amount:visible").size()) {
            var total = 0;
            $('tr:visible input[name="' + child + '-chosen"]:checked').each(function () {
                total += Shared.text_to_number($(this).closest("tr").find('input[name$="[amount]"]').val());
            });
            $("." + parent + "-amount:visible").html(total == 0 ? "" : Shared.number_to_currency_with_unit(total, 2, '.', ','));
        }
    };

    return {
        init: init,
        initAccounts: initAccounts,
        calculate: calculate
    }

})(jQuery, Shared)