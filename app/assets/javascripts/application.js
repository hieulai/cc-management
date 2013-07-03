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
//= require_tree .

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

//var add_fields = function(link, association, content){
//	var new_id = new Date().getTime();
//	var regexp = new RegExp("new_" + association, "g")
//	$(link).up().insert({
//		before: content.replace(regexp, new_id)
//	});
//}