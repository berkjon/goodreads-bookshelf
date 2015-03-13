helpers do

  def oauth_consumer
    raise RuntimeError, "You must set GR_API_KEY and GR_API_SECRET in your server environment." unless ENV['GR_API_KEY'] and ENV['GR_API_SECRET']
    @consumer ||= OAuth::Consumer.new(
      ENV['GR_API_KEY'],
      ENV['GR_API_SECRET'],
      site: "http://www.goodreads.com" )
  end

  def request_token
    # binding.pry
    if not session[:request_token]
      #below 'host_and_port' logic allows app to work locally and on Heroku
      host_and_port = request.host
      host_and_port << ":9393" if request.host == "localhost"
      session[:request_token] = oauth_consumer.get_request_token(
        oauth_callback: "http://#{host_and_port}/auth"
        )
    end
    session[:request_token]
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

OAuth::Consumer.new(ENV['GR_API_KEY'], ENV['GR_API_SECRET'], site: "http://www.goodreads.com" )
