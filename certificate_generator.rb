require 'openssl'
require 'byebug'

def generate_key
  OpenSSL::PKey::RSA.new(2048)
end

def generate_certificate(key, ca_cert, ca_key)
  name = OpenSSL::X509::Name.parse("/CN=Client")
  cert = OpenSSL::X509::Certificate.new
  cert.version = 2
  cert.serial = 1
  cert.not_before = Time.now
  cert.not_after = Time.now + 86400 * 365 # Valid for one year
  cert.public_key = key.public_key
  cert.subject = name
  cert.issuer = ca_cert.subject

  extension_factory = OpenSSL::X509::ExtensionFactory.new
  extension_factory.subject_certificate = cert
  extension_factory.issuer_certificate = ca_cert

  cert.add_extension(extension_factory.create_extension('basicConstraints', 'CA:FALSE'))
  cert.add_extension(extension_factory.create_extension('keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature'))
  cert.add_extension(extension_factory.create_extension('subjectKeyIdentifier', 'hash'))

  cert.sign(ca_key, OpenSSL::Digest.new('SHA256'))
  cert
end

def save_to_file(filename, data)
	File.open(filename, 'w') { |file| file.write(data.to_pem) }
end
  

ca_key = OpenSSL::PKey::RSA.new(File.read('ca_key.pem'))
ca_cert = OpenSSL::X509::Certificate.new(File.read('ca_cert.pem'))

key = generate_key
certificate = generate_certificate(key, ca_cert, ca_key)

save_to_file('client_key.pem', key)
save_to_file('client_cert.pem', certificate)

puts 'Client key and certificate generated and signed by the CA successfully.'
