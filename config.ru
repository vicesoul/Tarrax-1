require File.dirname(__FILE__) + '/config/environment'

if Rails.env.profile?
  use Rack::RubyProf, :path => File.dirname(__FILE__) + '/tmp/profile'
end

run ActionController::Dispatcher.new
