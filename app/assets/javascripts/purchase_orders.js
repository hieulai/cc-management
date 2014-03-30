//= require purchasable

var PurchaseOrder = (function ($, Shared, Purchasable) {
    var init = function () {
        Purchasable.init();
    };

    return {
        init: init
    }
})(jQuery, Shared, Purchasable);