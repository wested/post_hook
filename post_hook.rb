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
  params = JSON.parse(params[:payload])
  `ruby scripts/#{script_name} #{params}`
end