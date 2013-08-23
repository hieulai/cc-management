// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require cocoon
//= require jquery.poshytip
//= require jquery-editable-poshytip
//= require jquery-editable-rails
//= require autocomplete-rails
//= require_tree .
//= stub wkhtmltopdf_tableSplitHack

var bounceEffectRight = function(element){
  element.effect("bounce", {
    direction: "right",
    distance: 15,
    times: 4
  }, 1000);
  element.focus();
  return false;
}

var remove_fields = function(link){
	$(link).prev("input[type=hidden]").val("1");
	$(link).closest('.fields').hide();
}

var add_fields = function(link, association, content){
	var new_id = new Date().getTime();
	var regexp = new RegExp("new_" + association, "g")
	$(link).parent().before(content.replace(regexp, new_id));
}

var load_add_link = function(){
    if ((addTaskLink = $(".cocoon-container").find("#add_item:hidden")) && ($(".cocoon-container .nested-fields:visible").size() == 0)) {
        addTaskLink.data("association-insertion-node", 'this')
            .data("association-insertion-method", 'before')
            .show()
    }
}

$(document).ready(function() {
    load_add_link();

    $(document).on('click', '.trigger_add', function(){
        var container = $(this).closest(".cocoon-container");
        container.find("#add_item").data("association-insertion-node", '#' + $(this).closest(".nested-fields")[0].id)
            .data("association-insertion-method", 'after')
            .click();
    });
    $('.cocoon-container').bind('cocoon:after-insert', function (e, task_to_be_added) {
        if (addTaskLink = $("#add_item:visible")){
            addTaskLink.hide()
        }
        task_to_be_added.attr('id', 'item_' + new Date().getMilliseconds());
    });
    $('.cocoon-container').bind('cocoon:after-remove', function() {
          load_add_link();
    });
    $( "#tasksContainer" ).sortable({
        revert: true
    });
    $( "#tasksContainer" ).disableSelection();
    $('.tasklist').submit(function(){
      $(".task").each(function(){
          $(this).find(".position").val($(this).offset().top);
      })
    });
    $(document).on('click', 'input[type="submit"]', function(){
        $($(this).data("form")).submit();
    })
})

//var add_fields = function(link, association, content){
//	var new_id = new Date().getTime();
//	var regexp = new RegExp("new_" + association, "g")
//	$(link).up().insert({
//		before: content.replace(regexp, new_id)
//	});
//}