helpers do

  def truncate_string(string, max=350, end_string = ' ...')
    if string.nil? || string.length <= max
      return string
    else
      truncated_string = string.match( /(.{1,#{max - end_string.length}})(?:\s|\z)/ )[1]
      truncated_string << end_string
    end
  end

  # def paginated_books(user, next_page) #for infinite scroll
  #   per_page = 10
  #   sorted_books = user.books.order('user_rating DESC')
  #   lower = (next_page * 10) - per_page
  #   upper = (next_page * 10) - 1
  #   return next_books = sorted_books[lower..upper]
  # end

  def next_books_for_infinite_scroll(user, last_book_gr_review_id) #for infinite scroll
    per_page = 10
    sorted_books = user.books.order('user_rating DESC').map{|book| book.gr_review_id}
    last_book_index = sorted_books.find_index(last_book_gr_review_id.to_i)
    return next_books = sorted_books[(last_book_index+1)..(last_book_index+per_page)].map {|review_id| Book.find_by(gr_review_id: review_id)}
  end

end
