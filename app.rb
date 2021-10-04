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
  
  digest_format = /\A[0-9a-f]{2}\/[0-9a-f]{2}\/[0-9a-f]{60}\Z/

  all_files.all do |file|
    if (!!file.name.downcase.match(digest_format))
      filename = file.name.downcase[0,2] + file.name.downcase[3,2] + file.name.downcase[6,60]
      array_files.append(filename)
    end
  end
  array_files.sort!
  
  status  200
  body array_files.to_json
end


get '/files/:digest' do
  digest_raw = /\A[0-9a-f]{64}\Z/
  digest = params['digest'].downcase

  if (!!digest.match(digest_raw))
    storage = Google::Cloud::Storage.new(project_id: 'cs291a')
    bucket = storage.bucket 'cs291project2', skip_lookup: true
    newdigest = digest[0,2] + "/" + digest[2,2] + "/" + digest[4,60]
    file = bucket.file newdigest
    
    if (file != nil)
      status 200
      body file.download.read
      content_type file.content_type      
    else 
      status 404
    end

  else
    status 422
  end
end 


post '/files/' do
  file = params[:file]
  if file != nil
    filetemp = file['tempfile']
  end

  if file != nil and filetemp != nil and File.file?(filetemp)
    if filetemp.size > 1048576
      status 422
      return
    end
    txt = open(filetemp).read
    sha256 = Digest::SHA256.hexdigest txt

    newdigest = sha256[0,2] + "/" + sha256[2,2] + "/" + sha256[4,60]

    storage = Google::Cloud::Storage.new(project_id: 'cs291a')
    bucket = storage.bucket 'cs291project2', skip_lookup: true
    exist = bucket.file newdigest

    if exist == nil
      bucket.create_file filetemp, path = newdigest, content_type: file['type']
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


delete '/files/:digest' do
  digest_raw = /\A[0-9a-f]{64}\Z/
  digest = params['digest'].downcase

  if (!!digest.match(digest_raw))
    status 200
    storage = Google::Cloud::Storage.new(project_id: 'cs291a')
    bucket = storage.bucket 'cs291project2', skip_lookup: true
    newdigest = digest[0,2] + "/" + digest[2,2] + "/" + digest[4,60]
    file = bucket.file newdigest

    if (file != nil)
      file.delete
    end

  else
    status 422
  end
end