require 'sinatra'

get '/' do
  "Hello World!"
end

get '/img' do
  content_type 'image/png'
  `vnstati -m -i em0 -o -`
end
