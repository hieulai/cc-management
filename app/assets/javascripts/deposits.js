var Deposit = (function ($, Shared, Accounting) {
    var init = function () {
        Accounting.init("deposit", "receipt");
    };

    return {
        init: init
    }
})(jQuery, Shared, Accounting);