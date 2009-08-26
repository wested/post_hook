require 'rubygems'
require 'active_support'
require 'sinatra'

include JSON
%w(post_hook github_service_hook submodule_updater).each do |filename| 
  require("#{File.dirname(__FILE__)}/lib/#{filename}.rb")
end

get '/' do
  'Hello world!'
end

get '/favicon.ico' do
  # do nothing
end

post '/test' do
  payload = JSON.parse(params[:payload])
  updater = SubmoduleUpdater.new(payload)
  updater.update_submodule
end
