require 'rest-client'
require 'openssl'
require 'json'

CA_CERT_PATH = 'ca_cert.pem'
SERVER_URL = 'http://localhost:3000/certificate'

response = RestClient::Resource.new(SERVER_URL, verify_ssl: OpenSSL::SSL::VERIFY_PEER, ssl_ca_file: CA_CERT_PATH).get
data = JSON.parse(response.body)

if data['expiration_date']
  expiration_date = Time.parse(data['expiration_date'])
  current_time = Time.now

  if expiration_date > current_time
    puts "Certificate is valid. Expiration date: #{expiration_date}"
  else
    puts "Certificate has expired. Expiration date: #{expiration_date}"
  end
else
  puts 'Error: No expiration date found in the response.'
end
