GR_API_KEY = "ONBHGOyk3Zy1tq3meX1RZA" # Goodreads API Key
LT_API_KEY ="441231f2b92c881d462b94874bb5bfb7" # LibraryThing API Key

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

  api_response = HTTParty.get("https://www.goodreads.com/review/list/#{gr_id}.xml?key=#{GR_API_KEY}&v=2&per_page=200")
  parse_response(@user, api_response)

  redirect "/user/#{gr_id}"
end

get '/user/:gr_id' do
  @user = User.where(gr_id: params[:gr_id]).first

  erb :user_shelf_detail
end



