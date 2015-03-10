get '/' do
  erb :index
end

post '/user_id' do
  gr_id = params[:user_input]

  if User.where(gr_id: gr_id).first
    @user = User.where(gr_id: gr_id).first
    puts "Found user number #{@user.id}"
  else
    @user = User.create(gr_id: gr_id)
    puts "Created user #{@user.id}"
  end

  api_response = HTTParty.get("https://www.goodreads.com/review/list/#{gr_id}.xml?key=ONBHGOyk3Zy1tq3meX1RZA&v=2&per_page=200")
  parse_response(@user, api_response)
end



def parse_response(user, api_response)
  total_reviews = api_response['GoodreadsResponse']['reviews']['total'].to_i
  book_array = api_response['GoodreadsResponse']['reviews']['review']
  # binding.pry

    binding.pry
  book_array.each do |book|
    if book['shelves']['shelf'][0]['name'] == "read"
      new_book = user.books.create(
        title: book['book']['title'],
        author: book['book']['authors']['author']['name'],
        isbn10: book['book']['isbn'],
        isbn13: book['book']['isbn13'],
        publication_year: book['book']['publication_year'],
        publication_month: book['book']['publication_month'],
        num_pages: book['book']['num_pages'],
        description: book['book']['description'],
        user_rating: book['rating'],
        date_added: book['date_added'],
        gr_id: book['id'],
        gr_img_url: book['book']['image_url'],
        gr_review_id: book['book']['average_rating'],
        gr_book_url: book['book']['link'])
    end
  end

  # total_pages_required = total_reviews % 200
  # total_pages_required.times-1 do
end
