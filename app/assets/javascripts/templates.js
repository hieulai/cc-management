// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


var add_item = function(el){
  el = $(el);
  var categoryId = el.attr('id');
  var categoryValue = $('option:selected').val();

  $.ajax({
    url: "/categories/items/"+el.val()+".json",
    dataType: "json",
    beforeSend: function(xhr) {
      return $("#loading").show();
    }
  }).done(function(data, textStatus){
    $("input#" + categoryId).val(categoryValue);
    nestedFields = el.parents(".nested-fields");
    categoryItems = nestedFields.children(".category_items");
    categoryItems.fadeOut();
    categoryItems.html("");

    for(i = 0; i < data.length; i++){
      categoryItems.append("<p class='item' data-id='"+data[i].id+"'>"+data[i].name+"</p>").fadeIn();
    }
  });
}

$(document).ready(function(){
  $('#new_template').submit(function(){
    var selected = $(".template_categories").children('option:selected');
    if(selected.val() == ''){
      bounceEffectRight(selected);
      alert(console.log(selected));
    } else {
      alert(console.log(selected));
    }
  });
})