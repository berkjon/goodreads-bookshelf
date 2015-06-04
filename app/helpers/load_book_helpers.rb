module LoadBookHelpers

  def fetch_books_from_goodreads(user, page_num=1)
    return HTTParty.get("https://www.goodreads.com/review/list/#{user.gr_id}.xml?key=#{ENV['GR_API_KEY']}&v=2&page=#{page_num}&per_page=200&sort=rating")
  end

  def save_books_to_db(user, book_array)
    book_array.each do |book|
      # unless book_already_on_shelfworm_shelf?(user, book['book']['id'])
        # if hash_or_array_to_string(book['shelves']['shelf'], 'name').match(/(?<![\w\S])read(?![\w\d])/)
        if on_shelf?(book, 'read') && new_info_on_goodreads?(user, book) #skips books not yet read, and in DB but not changed on GR
          book_in_db = user.books.find_or_initialize_by(gr_review_id: book['id'])
          book_in_db.update(
            title: book['book']['title'],
            author: hash_or_array_to_string(book['book']['authors']['author'], 'name'),
            isbn10: book['book']['isbn'],
            isbn13: book['book']['isbn13'],
            publication_year: book['book']['publication_year'],
            publication_month: book['book']['publication_month'],
            num_pages: book['book']['num_pages'],
            description: book['book']['description'],
            user_rating: book['rating'],
            user_review: strip_text_if_not_nil(book['body']),
            date_added: book['date_added'],
            gr_review_id: book['id'],
            gr_book_id: book['book']['id'],
            gr_avg_rating: book['book']['average_rating'],
            gr_book_url: book['book']['link'],
          )
          if (book_in_db.cover_img_set_by_user == false) || book_in_db.cover_img_url.nil? #only update cover img URL if the user hasn't set it already
            book_in_db.cover_img_url = find_best_cover_img_url(book['book']['image_url'], book['book']['isbn13'])
          end
          book_in_db.save!
        end
      # end
    end
  end

  def next_api_page(api_response)
    reviews_start = api_response['GoodreadsResponse']['reviews']['start'].to_i
    reviews_end = api_response['GoodreadsResponse']['reviews']['end'].to_i
    reviews_total = api_response['GoodreadsResponse']['reviews']['total'].to_i

    reviews_per_api_call = reviews_end - (reviews_start - 1)

    if reviews_total == reviews_end
      return next_api_page = nil
    else
      return next_api_page = (reviews_end / reviews_per_api_call) + 1
    end
  end

  def book_already_on_shelfworm_shelf?(user, gr_book_id)
    !!(user.books.find_by(gr_book_id: gr_book_id))
  end

  def on_shelf?(book, shelf_name) #Checks if the book is on the user's 'Read' shelf on Goodreads
    bookshelves = []
    if book['shelves']['shelf'].is_a?(Array)
      book['shelves']['shelf'].each { |shelf| bookshelves << shelf['name'] }
    else #book is only on one shelf, so Goodreads returns it as a hash
      bookshelves << book['shelves']['shelf']['name']
    end

    bookshelves.include?(shelf_name)
    # hash_or_array_to_string(book['shelves']['shelf'], 'name').match(/(?<![\w\S])read(?![\w\d])/)
  end

  def new_info_on_goodreads?(user, book_info_from_gr) #Checks if the book review/info has been updated on Goodreads since being added to Shelfworm
    gr_review_id = book_info_from_gr['id']
    time_updated_on_gr = book_info_from_gr['date_updated'].to_datetime
    book_in_db = user.books.find_by(gr_review_id: gr_review_id)
    if book_in_db.nil? #Book not yet loaded to DB
      return true
    elsif time_updated_on_gr > book_in_db.updated_at #Book is in DB but GR has newer data
      return true
    else
      return false
    end
  end


  def hash_or_array_to_string(hash_or_array, key) #Handles situations where API data could either be a hash or an array (e.g. depending on number of authors), and if it's an array, converts everything to one string
    output_array = []
    if hash_or_array.is_a?(Array)
      hash_or_array.each { |element| output_array << element[key] }
    else
      output_array << hash_or_array[key]
    end
    output_string = output_array.compact.join(', ')
  end


  def strip_text_if_not_nil(xml_element)
    xml_element.nil? ? xml_element : xml_element.strip
  end

  def find_best_cover_img_url(gr_img_url, isbn13)
    covers = {}

    if isbn13.nil?
      return gr_img_url
      # return "https://s.gr-assets.com/assets/nophoto/book/111x148-bcc042a9c91a29c1d680899eff700a03.png"
    else
      gr_img_url.gsub!(/(?<=\d)(m\/)/, 'l/')
      gr_img_url_dimensions = FastImage.size(gr_img_url)
      gr_img_url_area = gr_img_url_dimensions.inject(:*) unless gr_img_url_dimensions.nil?
      covers[gr_img_url] = gr_img_url_area

      ol_img_url = "http://covers.openlibrary.org/b/isbn/#{isbn13}-L.jpg?default=false"
      ol_img_url_dimensions = FastImage.size(ol_img_url)
      ol_img_url_area = ol_img_url_dimensions.inject(:*) unless ol_img_url_dimensions.nil?
      covers[ol_img_url] = ol_img_url_area

      lt_img_url = "http://covers.librarything.com/devkey/#{ENV['LT_API_KEY']}/large/isbn/#{isbn13}"
      lt_img_url_dimensions = FastImage.size(lt_img_url)
      p "CURRENT ISBN13: #{isbn13}"
      p "LT_IMG_URL: #{lt_img_url}"
      p "LT_IMG_URL_DIMENSIONS: #{lt_img_url_dimensions}"
      lt_img_url_area = lt_img_url_dimensions.inject(:*) unless lt_img_url_dimensions.nil? || lt_img_url_dimensions.inject(:*) == 1
      covers[lt_img_url] = lt_img_url_area

      #add Google Books cover; requires API key and need to parse JSON response
      largest_img_url = covers.select {|k,v| v == covers.values.map(&:to_i).max}.keys.first
      return largest_img_url
    end
  end


end

helpers do
  include LoadBookHelpers
end