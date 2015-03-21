// var windo = $(window);

// $('.back').on('click', function(event){
//   var refreshing = false;
//   console.log(windo.scrollTop(), windo.height(), $(document).height());
//   console.log($(this));

//   if(Math.floor(windo.scrollTop() + windo.height()) >= $(document).height()-10 && !refreshing) {
//     console.log('refreshing!');

//     refreshing = true;

//     $.ajax({
//       url: '/user/infinite_scroll'
//     }).done(function(html){
//       $('.bookshelf').append(html);
//       setTimeout(function(){refreshing = false}, 1000);

//     }).fail(function(){
//       console.log("you failed at infinite scroll");
//     })
//     console.log("back inside if condition");
//   }
// })

$(document).ready(function() {
  console.log('ready!');
  // $('.back').click(function() {
  $(window).scroll(function(event) {
    console.log(event)
    console.log(event.eventPhase)
    // debugger;
    if(Math.floor($(window).scrollTop() + $(window).height()) >= $(document).height()-10) {
      $.ajax({
        url: '/user/infinite_scroll'
      }).done(function(html){
        console.log(html)
        // $('.bookshelf').append(html);
        // event.bubbles = false;

        // event.stopPropagation();
      }).fail(function(){
        console.log("you failed at infinite scroll");
        console.log("\n")
      })
      console.log("back inside if condition");
    }
  });


});

