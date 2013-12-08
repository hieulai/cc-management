jQuery.extend(jQuery.fn.dataTableExt.oSort, {
    "currency-pre": function (a) {
        a = (a === "-") ? 0 : a.replace(/[^\d\-\.]/g, "");
        return parseFloat(a);
    },

    "currency-asc": function (a, b) {
        return a - b;
    },

    "currency-desc": function (a, b) {
        return b - a;
    }
});

jQuery.extend( jQuery.fn.dataTableExt.oSort, {
    "date-us-pre": function ( a ) {
        var b = a.match(/(\d{1,2})\-(\d{1,2})\-(\d{2,4})/),
            month = b[1],
            day = b[2],
            year = b[3];

        if(year.length == 2){
            if(parseInt(year, 10)<70) year = '20'+year;
            else year = '19'+year;
        }
        if(month.length == 1) month = '0'+month;
        if(day.length == 1) day = '0'+day;

        var tt = year+month+day;
        return  tt;
    },
    "date-us-asc": function ( a, b ) {
        return a - b;
    },

    "date-us-desc": function ( a, b ) {
        return b - a;
    }
});

jQuery.fn.dataTableExt.aTypes.unshift(
    function ( sData )
    {
        if (sData !== null && sData.match(/\d{1,2}\-\d{1,2}\-\d{2,4}/)){
            return 'date-us';
        }

        if (sData !== null && sData.match(/[^\d\-\.]/)){
            return 'currency';
        }

        return null;
    }
);