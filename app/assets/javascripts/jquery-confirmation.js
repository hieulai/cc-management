$.rails.allowAction = function (link) {
    if (!link.attr('data-confirm')) {
        return true;
    }
    $.rails.showConfirmDialog(link);
    return false;
};

$.rails.confirmed = function (link) {
    link.removeAttr('data-confirm');
    link.trigger('click.rails');
};

$.rails.showConfirmDialog = function (link) {
    var title = link.data('title'),
        message = link.data('confirm') || '',
        isInfo = link.data('info') == 'true';

    $.rails.createConfirmDialog(title, message, isInfo);
    $('#confirmation-dialog .confirm').on('click', function () {
        $.rails.confirmed(link);
    });
};


$.rails.createConfirmDialog = function (title, message, isInfo) {
    var header, body, footer, dialog;

    header = "<div class=\"modal-header\">";
    header += "<a class=\"close\" data-dismiss=\"modal\">x</a>";
    header += "<h3>" + title + "</h3>";
    header += "</div>";

    body = "<div class=\"modal-body\">" + message + "</div>";
    if (isInfo) {
        footer = "<div class=\"modal-footer\">";
        footer += "<a data-dismiss=\"modal\" class=\"btn\" id=\"cancel_btn\">OK</a>";
        footer += "</div>";
    } else {
        footer = "<div class=\"modal-footer\">";
        footer += "<a data-dismiss=\"modal\" class=\"btn\" id=\"cancel_btn\">Cancel</a>";
        footer += "<a data-dismiss=\"modal\" class=\"btn btn-primary confirm\" id=\"confirm_btn\">OK</a>";
        footer += "</div>";
    }
    dialog = "<div class=\"modal\" id=\"confirmation-dialog\">" + header + body + footer + "</div>";

    $(dialog).modal();
}