# Require config/environment.rb
require ::File.expand_path('../config/environment',  __FILE__)

set :app_file, __FILE__

map "/" do
  run Sinatra::Application
end

map "/resque" do
  run Resque::Server.new
end