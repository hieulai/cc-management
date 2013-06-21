// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
var add_item = function(el){
  el = $(el)
  $.ajax({
    url: "/categories/items/"+el.val()+".json",
    dataType: "json",
    beforeSend: function(xhr) {
      return $("#loading").show();
    }
  }).done(function(data, textStatus){
      nestedFields = el.parents(".nested-fields")
      categoryItems = nestedFields.children(".category_items")
      categoryItems.fadeOut()
      categoryItems.html("")

      for(i = 0; i < data.length; i++){
        categoryItems.append("<p class='item' data-id='"+data[i].id+"'>"+data[i].name+"</p>").fadeIn()
      }
  });
}