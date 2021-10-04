require 'sinatra'
require 'google/cloud/storage'
require 'digest'
require 'json'

get '/' do
  redirect to("/files/"), 302
end

get '/files/' do
  storage = Google::Cloud::Storage.new(project_id: 'cs291a')
  bucket = storage.bucket 'cs291project2', skip_lookup: true
  all_files = bucket.files
  array_files = []
  all_files.all do |file|
    array_files.append(file.name.downcase)
  end
  array_files.sort!

  #puts array_files.to_json
  array_files.to_json
end

post '/' do
  require 'pp'
  PP.pp request
  "POST\n"
end