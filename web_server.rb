require 'sinatra'
require 'openssl'

set :bind, '0.0.0.0'
set :port, 3000

CERTIFICATE_PATH = 'client_cert.pem'
KEY_PATH = 'client_key.pem'

get '/certificate' do
  cert = OpenSSL::X509::Certificate.new(File.read(CERTIFICATE_PATH))
  expiration_date = cert.not_after
  { expiration_date: expiration_date.to_s }.to_json
end
