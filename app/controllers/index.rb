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

  api_response = HTTParty.get("https://www.goodreads.com/review/list/#{gr_id}.xml?key=#{ENV['GR_API_KEY']}&v=2&per_page=200")
  binding.pry
  parse_response(@user, api_response)

  redirect "/user/#{gr_id}"
end

# COUNTER = 0
get '/user/infinite_scroll' do
  # session[:counter] = session[:counter] ?
  #                     session[:counter] + 1 : 1
  # binding.pry
  # p "COUNTER: #{COUNTER}"
  # COUNTER += 1
  # p "COUNTER: #{COUNTER}"
  # p "session[:sorted_book_ids]: count: #{session[:sorted_book_ids].length} contents: #{session[:sorted_book_ids]}"
  all_books = session[:sorted_book_ids]
  next_book_ids = all_books.shift(10)
  session[:sorted_book_ids] = all_books

  # session[:books_already_displayed] += next_book_ids
  # p "session[:books_already_displayed]: count: #{session[:books_already_displayed].length} contents: #{session[:books_already_displayed]}"
  # p "next_book_ids: #{next_book_ids}"
  # p "session[:sorted_book_ids]: count: #{session[:sorted_book_ids].length} contents: #{session[:sorted_book_ids]}"
  more_books = next_book_ids.map { |id| Book.find(id) }
  erb :_more_books, locals: {more_books: more_books}
end

get '/user/:gr_id' do
  @user = User.where(gr_id: params[:gr_id]).first
  books_array = @user.books.sort_by { |book| book.user_rating.to_i }.reverse
  @first_20_books = books_array.shift(20)
  session[:sorted_book_ids] = books_array.map{|book| book.id} #remaining books
  session[:books_already_displayed] = []
  erb :user_shelf
end


get '/user/:gr_id/detail' do
  @user = User.where(gr_id: params[:gr_id]).first
  erb :user_shelf_detail
end

############## WIP #################

get '/sign_in_with_gr' do
  # binding.pry
  redirect create_request_token.authorize_url
end

get '/sign_out' do
   session.clear
   redirect '/'
end

# get '/profile/:gr_id' do

# end

get '/auth' do

  puts "params: #{params}"
  # binding.pry
  puts "REQUEST TOKEN: #{session[:request_token]}"
  @access_token = use_request_token.get_access_token(oauth_verifier: params[:oauth_token])

  puts "access token: #{@access_token}"
  current_user_id = @access_token.get('/api/auth_user')
  puts "current_user_id: #{current_user_id}"

  current_user_object = @access_token.get('/api/auth_user')
  current_user_parsed = Nokogiri::XML(current_user_object.body)
  current_user_id = current_user_parsed.xpath('//user').first['id']
  current_user_full_name = current_user_parsed.xpath('//name').first.text

  user = User.find_or_create_by(gr_id: current_user_id)
  user.gr_oauth_token = @access_token.token
  user.gr_oauth_secret = @access_token.secret
  user.gr_full_name = current_user_full_name
  user.save

  session[:user_id] = user.id
  # binding.pry

  redirect "/profile/#{user.id}"
end

get '/profile/:id' do
  p "MADE IT INSIDE PROFILE!"
  p session
end
