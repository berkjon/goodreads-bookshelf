$(document).ready(function() {
  var fetching = false;

  console.log('ready!');
  $(window).scroll(function(event) {
    // console.log(event)
    // console.log(event.eventPhase)
    // debugger;
    if(Math.floor($(window).scrollTop() + $(window).height()) >= $(document).height()-10 && !fetching) {
      fetching = true;
      console.log('TRIGGERED INFINITE SCROLL');
      $.ajax({
        url: '/user/infinite_scroll'
      }).done(function(html){
        fetching = false;
        // console.log(html)
        $('.bookshelf').append(html);
      }).fail(function(){
        fetching = false;
        console.log("you failed at infinite scroll");
      })
    }
  });
});

