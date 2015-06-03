get '/' do
  erb :index
end


post '/user_id' do #create bookshelf for unregistered user
  if params[:gr_id] =~ /^[0-9]/ #if a number is entered
    user = User.find_or_create_by(gr_id: params[:gr_id])
    api_response = fetch_books_from_goodreads(user)
    first_20_books = api_response['GoodreadsResponse']['reviews']['review'][0..19]

    save_books_to_db(user, first_20_books)
    Resque.enqueue(LoadNewBooks, user, api_response, 20)
    redirect "/#{user.gr_id}"
  else #a number wasn't provided
    redirect '/' #TODO: Notify user that they can only pass in a number
  end
end


post '/profile/:gr_id/register' do #add username to new acct
  user = User.find_by(gr_id: params[:gr_id])
  if user.nil? || current_user.gr_id != params[:gr_id].to_i
    redirect '/'
  else
    puts "Adding username '#{params[:username]}' to GR acct# #{params[:gr_id]}"
    user.username = params[:username]
    user.save!
    redirect "/#{params[:username]}"
  end
end


# get '/user/infinite_scroll' do
#   all_books = session[:sorted_book_ids]
#   next_book_ids = all_books.shift(10)
#   session[:sorted_book_ids] = all_books
#   more_books = next_book_ids.map { |id| Book.find(id) }
#   erb :_more_books, locals: {more_books: more_books}, layout: false
# end

get '/users/:gr_id/infinite_scroll' do
  user = User.find_by(gr_id: params[:gr_id])
  # puts params[:next_page]
  # more_books = paginated_books(user, params[:next_page])
  puts params[:last_book_id]
  more_books = next_books_for_infinite_scroll(user, params[:last_book_id])
  erb :_more_books, locals: {more_books: more_books}, layout: false
end


############## GOODREADS SIGN IN / OAUTH #################

get '/sign_in_with_gr' do
  redirect create_request_token.authorize_url
end


get '/auth' do #callback from Goodreads OAuth
  puts "params: #{params}"
  puts "REQUEST TOKEN: #{session[:request_token]}"
  @access_token = use_request_token.get_access_token(oauth_verifier: params[:oauth_token])

  puts "access token: #{@access_token}"
  current_user_id = @access_token.get('/api/auth_user')
  puts "current_user_id: #{current_user_id}"

  current_user_object = @access_token.get('/api/auth_user')
  current_user_parsed = Nokogiri::XML(current_user_object.body)
  current_user_id = current_user_parsed.xpath('//user').first['id']
  current_user_full_name = current_user_parsed.xpath('//name').first.text

  user = User.find_or_initialize_by(gr_id: current_user_id)
  # user.id.nil? ? new_user = true : new_user = false
  # user.gr_oauth_token.nil? ? first_time_oauth = true : first_time_oauth = false
  user.gr_oauth_token = @access_token.token
  user.gr_oauth_secret = @access_token.secret
  user.gr_full_name = current_user_full_name
  user.save!
  # fetch_books_from_gr_and_save_to_db(user)
  Resque.enqueue(LoadNewBooks, user)

  session[:user_id] = user.id

  if current_user.username.nil? #if user hasn't created an account yet
    redirect "/profile/#{user.gr_id}/new"
  else #if it's a returning user
    redirect "/#{current_user.username}"
  end
end


get '/sign_out' do
   session.clear
   redirect '/'
end


get '/profile/:username' do
  if current_user.username == params[:username]
    user = User.find_by(username: params[:username])
    erb :user_profile, locals: {user: user}
  else
    halt 403, "Sorry, you are not authorized to view this page :("
  end
end


get '/profile/:gr_id/new' do #Get username to create new user account
  puts "CURRENT_USER.GR_ID: #{current_user.gr_id}"
  puts "PARAMS.GR_ID: #{params[:gr_id]}"
  user = User.find_by(gr_id: params[:gr_id])
  if current_user.gr_id.to_s == params[:gr_id]
    erb :new_user, locals: {user: user}
  else
    halt 403, "Sorry, you are not authorized to view this page :("
  end
end


get '/logout' do
  logout
  redirect '/'
end


############## MODIFYING COVERS AND DELETING BOOKS FROM SHELF #################

put '/:gr_id/books/:gr_review_id' do #update cover image URL
  if current_user.gr_id == params[:gr_id]
    user = User.find_by(gr_id: params[:gr_id])
    book = user.books.find_by(gr_review_id: params[:gr_review_id])
    book.cover_img_url = params[:new_book_cover_url]
    book.cover_img_set_by_user = true
    book.save!
    redirect "/<%= user.gr_id %>/shelf/modify"
  else
    puts "Can't modify book information of another user"
  end
end

delete '/:gr_id/books/:gr_review_id' do #delete a book from bookshelf
  if current_user.gr_id == params[:gr_id]
    user = User.find_by(gr_id: params[:gr_id])
    book = user.books.find_by(gr_review_id: params[:gr_review_id])
    book.destroy!
    redirect "/<%= user.gr_id %>/shelf/modify"
  else
    puts "Can't modify book information of another user"
  end
end


### Keep these routes last ###

get '/:user_identifier' do #for both registered and unregistered users
  if params[:user_identifier] =~ /^[0-9]/ #if a GR user id is being passed in
    if @user = User.find_by(gr_id: params[:user_identifier]) #if bookshelf has already been created
      if @user.username #if an account already exists with a custom username
        redirect "/#{@user.username}"
      else #bookshelf already exists but is not claimed by the owner
        books_array = @user.books.order('user_rating DESC').ids
        first_20_books = books_array.shift(20)
        @first_20_book_objects = first_20_books.map {|id| Book.find(id)}
        session[:sorted_book_ids] = books_array
        session[:books_already_displayed] = []
        erb :user_shelf_unregistered
      end
    else #bookshelf has not been created for the user yet
      puts "ERROR: Can't find anybody on Shelfworm with user_id #{params[:user_identifier]}."
      redirect '/' #TODO: Tell viewer that a bookshelf has not been created yet; must do from homepage
    end

  else #a username is being passed in (not a Goodreads ID#)
    if @user = User.find_by(username: params[:user_identifier]) #username is successfully found
      books_array = @user.books.order('user_rating DESC').ids
      first_20_books = books_array.shift(20)
      @first_20_book_objects = first_20_books.map {|id| Book.find(id)}
      session[:sorted_book_ids] = books_array
      session[:books_already_displayed] = []
      erb :user_shelf_registered
    else #username not found in DB
      puts "ERROR: User '#{params[:user_identifier]}' does not exist."
      redirect '/' #TODO: Render a page saying user does not exist
    end
  end
end

get '/:gr_id/shelf/modify' do
  if current_user.gr_id == params[:gr_id]
    erb :modify_shelf
  else
    halt 403, "Sorry, you are not authorized to view this page :("
  end
end