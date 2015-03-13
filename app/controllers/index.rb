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
  parse_response(@user, api_response)

  redirect "/user/#{gr_id}"
end

COUNTER = 0
get '/user/infinite_scroll' do
  # binding.pry
  p "COUNTER: #{COUNTER}"
  COUNTER += 1
  p "COUNTER: #{COUNTER}"
  p "session[:sorted_book_ids]: count: #{session[:sorted_book_ids].length} contents: #{session[:sorted_book_ids]}"
  next_book_ids = session[:sorted_book_ids].shift(10)
  session[:books_already_displayed] = session[:books_already_displayed] + next_book_ids
  p "session[:books_already_displayed]: count: #{session[:books_already_displayed].length} contents: #{session[:books_already_displayed]}"
  p "next_book_ids: #{next_book_ids}"
  p "session[:sorted_book_ids]: count: #{session[:sorted_book_ids].length} contents: #{session[:sorted_book_ids]}"
  more_books = next_book_ids.map { |id| Book.find(id) }
  erb :_more_books, locals: {more_books: more_books}
end

get '/user/:gr_id' do
  @user = User.where(gr_id: params[:gr_id]).first
  books_array = @user.books.sort_by! { |book| book.user_rating.to_i }.reverse
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
  redirect request_token.authorize_url
end

# get '/sign_out' do
#   session.clear
#   redirect '/'
# end

# get '/profile/:gr_id' do

# end

get '/auth' do
  # binding.pry
  @access_token = request_token.get_access_token(oauth_token: params[:oauth_token])
  # @access_token = request_token.params[:oauth_token]
  session.delete(:request_token)

  user = User.find_or_create_by(username: @access_token.params[:screen_name])
  user.oauth_token = @access_token.token
  user.oauth_secret = @access_token.secret
  user.save

  session[:user_id] = user.id

  redirect "/profile/#{user.id}"
end

get '/profile/:id' do
  p "MADE IT INSIDE PROFILE!"
end
