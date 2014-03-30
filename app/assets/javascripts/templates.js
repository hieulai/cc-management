var Template = (function ($, Shared) {
    var init = function () {
        $(document).on('railsAutocomplete.select', '.template-fields .template-item-name', function (event, data) {
            $(this).next(".template-item-id").val(data.item.id);
        });
    };

    return {
        init: init
    }
})(jQuery, Shared);