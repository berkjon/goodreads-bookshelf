$(document).ready(function() {

  // $('.back').click(function() {
  $(window).scroll(function() {
    // debugger;
    if(Math.floor($(window).scrollTop() + $(window).height()) >= $(document).height()-10) {
      $.ajax({
        url: '/user/infinite_scroll'
      }).done(function(html){
        $('.bookshelf').append(html);
      }).fail(function(){
        console.log("you failed at infinite scroll");
      })
      console.log("back inside if condition");
    }
  });

});

