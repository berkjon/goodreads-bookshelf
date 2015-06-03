$(document).ready(function() {
  var fetching = false;

  $(window).scroll(function(event) {
    // console.log(event)
    // console.log(event.eventPhase)
    // debugger;
    if(Math.floor($(window).scrollTop() + $(window).height()) >= $(document).height()-10 && !fetching) {
      fetching = true;
      addLoader();
      var last_book_id = $('.flip-container').last().data('gr-review-id');
      var user_id = $('.bookshelf').data('gr-id');
      console.log('Infinite scroll triggered.');
      $.ajax({
        data: {last_book_id: last_book_id},
        url: '/users/'+user_id+'/infinite_scroll'
      }).done(function(html){
        fetching = false;
        removeLoader();
        $('.bookshelf').append(html);
      }).fail(function(){
        fetching = false;
        console.log("Infinite scroll failed.");
      })
    }
  });

});

function addLoader(){
  var loader = "<div class='loader-wrapper'><div class='loader'>Loading more books...</div></div>"
  $('.bookshelf-wrapper').append(loader)
}

function removeLoader(){
  $('.loader-wrapper').remove()
}
