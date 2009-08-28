require 'rubygems'
require 'rack'
require 'active_support'
require 'sinatra'
require 'popen4'
require 'ostruct'

configure do
  Log = Logger.new(File.join('log', "post_hook_production.log"))
  Log.level  = Logger::INFO 
end

include JSON

%w(post_hook github_service_hook submodule_updater notification).each do |filename| 
  require("#{File.dirname(__FILE__)}/lib/#{filename}.rb")
end

get "/foo" do
  Log.info "log message!"
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
  updater.update
end
