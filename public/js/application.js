$(document).ready(function() {

  $.ajax({
    type: 'get',
    url: 'https://www.goodreads.com/review/list/8403316.xml?key=ONBHGOyk3Zy1tq3meX1RZA&v=2'
  }).done(function(xml){
    // do work on xml response
    debugger;
  })

});
