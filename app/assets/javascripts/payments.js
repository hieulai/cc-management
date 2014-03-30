var Payment = (function ($, Shared, Accounting) {
    var init = function () {
        Accounting.init("payment", "bill");
    };

    return {
        init: init
    }
})(jQuery, Shared, Accounting);