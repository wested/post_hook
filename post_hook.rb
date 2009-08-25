require 'rubygems'
require 'sinatra'

get '/' do
  'Hello world!'
end

get '/favicon.ico' do
  # do nothing
end

post '/test' do
  script_name = 'touch_file.rb'
  `ruby scripts/#{script_name}`
end