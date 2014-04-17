var Payment = (function ($, Shared, Accounting) {
    var init = function () {
        Accounting.init("payment", "bill");
        Shared.initPeopleSelector(show_bills);
    };

    var show_bills = function (pId, pType) {
        var $peopleLink = $("#hidden_people_link");
        var href = $peopleLink.attr("href");
        href = Shared.updateQueryStringParameter(href, "payment[payer_id]", pId);
        href = Shared.updateQueryStringParameter(href, "payment[payer_type]", pType);
        $peopleLink.attr("href", href).click();
    }

    return {
        init: init
    }
})(jQuery, Shared, Accounting);