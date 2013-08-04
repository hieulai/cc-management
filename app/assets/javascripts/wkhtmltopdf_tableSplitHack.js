/**
 * WkHtmlToPdf table splitting hack.
 *
 * Script to automatically split multiple-pages-spanning HTML tables for PDF
 * generation using webkit.
 *
 * To use, you must adjust pdfPage object's contents to reflect your PDF's
 * page format.
 * The tables you want to be automatically splitted when the page ends must
 * have a class name of "splitForPrint" (can be changed).
 * Also, it might be a good idea to update the splitThreshold value if you have
 * large table rows.
 *
 * Dependencies: jQuery.
 *
 * WARNING: WorksForMe(tm)!
 * If it doesn't work, first check for javascript errors using a webkit browser.
 *
 * @author Florin Stancu <niflostancu@gmail.com>
 * @version 1.0
 * @license http://www.opensource.org/licenses/mit-license.php MIT License
 */

/**
 * PDF page settings.
 * Must have the correct values for the script to work.
 * All numbers must be in inches (as floats)!
 * Use google to convert margins from mm to in ;)
 *
 * @type {Object}
 */

var pdfPage = {
    width: 8.26, // inches
    height: 11.69, // inches
    margins: {
        top: 0.393701, left: 0.393701,
        right: 0.393701, bottom: 0.393701
    }
};

/**
 * The distance to bottom of which if the element is closer, it should moved on
 * the next page. Should be at least the element (TR)'s height.
 *
 * @type {Number}
 */
var splitThreshold = 40;

/**
 * Class name of the tables to automatically split.
 * Should not contain any CSS definitions because it is automatically removed
 * after the split.
 *
 * @type {String}
 */
var splitClassName = 'splitForPrint';

/**
 * Window load event handler.
 * We use this instead of DOM ready because webkit doesn't load the images yet.
 */
$(window).load(function () {
    // get document resolution
    var dpi = $('<div id="dpi"></div>')
        .css({
            height: '1in', width: '1in',
            top: '-100%', left: '-100%',
            position: 'absolute'
        })
        .appendTo('body')
        .height();

    // page height in pixels
    var pageHeight = Math.ceil(
        (pdfPage.height - pdfPage.margins.top - pdfPage.margins.bottom) * dpi);

    // temporary set body's width and padding to match pdf's size
    var $body = $('body');
    $body.css('width', (pdfPage.width - pdfPage.margins.left - pdfPage.margins.right)+'in');
    $body.css('padding-left', pdfPage.margins.left+'in');
    $body.css('padding-right', pdfPage.margins.right+'in');

    /*
     * Cycle through all tables and split them in two if necessary.
     * We need this in a loop for it to work for tables spanning multiple pages:
     * first, the table is split in two; then, if the second table also spans multiple
     * pages, it is also split and so on until there are no more.
     * Because when modifying the upper tables, the elements' positions will change,
     * we need to maintain an offset correction value.
     *
     * This method can be used for all document's elements (not just tables), but the
     * overhead would be too big. Use CSS's `page-break-inside: avoid` which works for
     * divs and many other block elements.
     */
    var tablesModified = true;
    var offsetCorrection = 0;
    while (tablesModified) {
        tablesModified = false;

        $('table.'+splitClassName).each(function(){
            var $t = $(this);

            // clone the original table
            var copy = $t.clone();
            copy.find('tbody > tr').remove();
            var $cbody = copy.find('tbody');
            var found = false;
            $t.removeClass(splitClassName); // for optimisation

            var newOffsetCorrection = offsetCorrection;
            $('tbody tr', $t).each(function(){
                var $tr = $(this);

                // compute element's top position and page's end
                var top = $tr.offset().top;
                var ctop = offsetCorrection + top;
                var pageEnd = (Math.floor(ctop/pageHeight)+1)*pageHeight;

                // use for debugging (prints TR's top inside its first column)
                // $tr.find('td:first').html(ctop);

                // check whether the current element is close to the page's end.
                if (ctop >= (pageEnd - splitThreshold)) {
                    // move the element to the cloned table
                    $tr.detach().appendTo($cbody);
                    if (!found) {
                        // compute the new offset correction
                        newOffsetCorrection += (pageEnd - ctop);
                    }
                    found = true;
                }
            });

            // if the cloned table has no contents...
            if (!found)
                return;

            offsetCorrection = newOffsetCorrection;
            tablesModified = true;
            // add a page-breaking div
            // (with some whitespace to correctly show table top border)
            var $br = $('<div style="height: 10px;"></div>')
                .css('page-break-before', 'always');
            $br.insertAfter($t);
            copy.insertAfter($br);
        });
    }

    // restore body's padding
    $body.css('padding-left', 0);
    $body.css('padding-right', 0);

});