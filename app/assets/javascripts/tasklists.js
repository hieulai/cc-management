var TaskList = (function ($) {
   var init = function(){
       $( "#tasksContainer" ).sortable({
           revert: true
       });
       $( "#tasksContainer" ).disableSelection();
       $('.tasklist').submit(function(){
           $(".task").each(function(){
               $(this).find(".position").val($(this).offset().top);
           })
       });
   };

   return {
       init: init
   }
})(jQuery)