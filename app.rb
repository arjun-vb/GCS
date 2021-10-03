require 'sinatra'

get '/' do
  redirect to("/files/"), 302
end

post '/' do
  require 'pp'
  PP.pp request
  "POST\n"
end
