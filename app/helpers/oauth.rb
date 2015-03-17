helpers do

  def oauth_consumer
    raise RuntimeError, "You must set GR_API_KEY and GR_API_SECRET in your server environment." unless ENV['GR_API_KEY'] and ENV['GR_API_SECRET']
    @consumer ||= OAuth::Consumer.new(
      ENV['GR_API_KEY'],
      ENV['GR_API_SECRET'],
      site: "http://www.goodreads.com")
  end

  def use_request_token
    #session[:request_token].tap(x){  }
    session.delete(:request_token)
  end

  def create_request_token
    puts "GETTING NEW TOKEN"
    session[:request_token] = oauth_consumer.get_request_token
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !current_user.nil?
  end

  def logout
    session.clear
  end

end

