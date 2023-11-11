require 'openssl'
require 'byebug'

def generate_ca_key
  OpenSSL::PKey::RSA.new(2048)
end

def generate_ca_certificate(ca_key)
  ca_name = OpenSSL::X509::Name.parse('/CN=CA')
  ca_cert = OpenSSL::X509::Certificate.new
  ca_cert.version = 2
  ca_cert.serial = 0
  ca_cert.not_before = Time.now
  ca_cert.not_after = Time.now + 86400
  ca_cert.public_key = ca_key.public_key
  ca_cert.subject = ca_name

  extension_factory = OpenSSL::X509::ExtensionFactory.new
  extension_factory.subject_certificate = ca_cert
  extension_factory.issuer_certificate = ca_cert


  ca_cert.add_extension(extension_factory.create_extension('basicConstraints', 'CA:TRUE', true))
  ca_cert.add_extension(extension_factory.create_extension('keyUsage', 'keyCertSign', true))
  ca_cert.add_extension(extension_factory.create_extension('subjectKeyIdentifier', 'hash'))

  ca_cert.sign(ca_key, OpenSSL::Digest.new('SHA256'))
  ca_cert
end

def save_to_file(filename, data)
  File.open(filename, 'w') { |file| file.write(data.to_pem) }
end

ca_key = generate_ca_key
ca_cert = generate_ca_certificate(ca_key)

save_to_file('ca_key.pem', ca_key)
save_to_file('ca_cert.pem', ca_cert)

puts 'Certificate Authority (CA) key and certificate generated successfully.'
