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
  status  201
  body array_files.to_json
end

get '/files/:digest' do
  storage = Google::Cloud::Storage.new(project_id: 'cs291a')
  bucket = storage.bucket 'cs291project2', skip_lookup: true
  file = bucket.file digest
  
  puts file.name
end 

post '/files/' do
  file = params[:file]

  if request.content_length.to_i > 1048576
    status 422
  elsif file != nil and file['tempfile'] != nil
    txt = open(file['tempfile']).read
    sha256 = Digest::SHA256.hexdigest txt

    newdigest = sha256[0,2] + "/" + sha256[2,2] + "/" + sha256[4,60]
    puts sha256
    puts newdigest

    storage = Google::Cloud::Storage.new(project_id: 'cs291a')
    bucket = storage.bucket 'cs291project2', skip_lookup: true
    exist = bucket.file newdigest

    if exist == nil
      #bucket.createfile file['tempfile'], path = newdigest, content_type = file['type']
      response = { uploaded: sha256 }.to_json
      status  201 
      body response
    else
      status 409
    end
  else
    status 422
  end

end

post '/' do
  require 'pp'
  PP.pp request
  "POST\n"
end