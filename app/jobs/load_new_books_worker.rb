# Helpful: http://tutorials.jumpstartlab.com/topics/performance/background_jobs.html

class LoadNewBooks
  extend LoadBookHelpers

  @queue = :load_new_books

  def self.perform(user_hash, api_response, books_already_saved=0)
    puts "INSIDE RefreshBookshelf RESQUE WORKER"
    puts user_hash
    user = User.find_by(gr_id: user_hash['gr_id'])

    book_array = api_response['GoodreadsResponse']['reviews']['review']
    remaining_books_to_save = book_array[books_already_saved..-1]

    save_books_to_db(user, remaining_books_to_save)

    until next_api_page(api_response).nil?
      puts "Next API page: #{next_api_page(api_response)}"
      api_response = fetch_books_from_goodreads(user, next_api_page(api_response))
      book_array = api_response['GoodreadsResponse']['reviews']['review']
      save_books_to_db(user, book_array)
    end
  end

end
