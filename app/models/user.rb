class User < ActiveRecord::Base
  has_many :books

  def sorted_books
    self.books.order(user_rating: :desc, title: :asc)
  end

end
