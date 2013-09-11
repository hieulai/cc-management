$.ui.autocomplete.prototype._renderItem = function( ul, item) {
    var t = item.label;
    if (item.id != ""){
        var re = new RegExp(this.term,"gi") ;
        var t = t.replace(re,"<strong>" +
            this.term +
            "</strong>");
    }
    return $( "<li></li>" )
        .data( "item.autocomplete", item )
        .append( "<a>" + t + "</a>" )
        .appendTo( ul );
};