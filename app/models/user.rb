class User < ActiveRecord::Base
  has_many :books

  def sorted_books
    self.books.order(user_rating: :desc, title: :asc)
  end

  def first_books(num_of_books=20)
    books_array = self.sorted_books.ids #just save the IDs in memory, not the whole object
    return books_array.shift(num_of_books).map {|id| Book.find(id)} #only need the first 20 books as objects
  end

end
