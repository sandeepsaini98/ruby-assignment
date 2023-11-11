require 'openssl'

#Keys

#Creating a key
key = OpenSSL::PKey::RSA.new 2048

open 'private_key.pem', 'w' do |io| io.write key.to_pem end
open 'public_key.pem', 'w' do |io| io.write key.public_key.to_pem end

key2 = OpenSSL::PKey.read File.read 'private_key.pem'
key2.public?
key2.private?


key3 = OpenSSL::PKey.read File.read 'public_key.pem'
key3.public?
key3.private?

# Encryption & Decryption


wrapped_key = key.public_encrypt key

original_key = key.private_decrypt wrapped_key

## X509 Certificates

# Creating a Certificate

key = OpenSSL::PKey::RSA.new 2048
name = OpenSSL::X509::Name.parse '/CN=nobody/DC=example'

cert = OpenSSL::X509::Certificate.new
cert.version = 2
cert.serial = 0
cert.not_before = Time.now
cert.not_after = Time.now + 3600

cert.public_key = key.public_key
cert.subject = name

## Certificate Extensions

extension_factory = OpenSSL::X509::ExtensionFactory.new nil, cert
cert.add_extension \
    extension_factory.create_extension('basicConstraints', 'CA:FALSE', true)

cert.add_extension \
    extension_factory.create_extension(
        'keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature'
    )

cert.add_extension \
    extension_factory.create_extension('subjectKeyIdentifier', 'hash')

##Signing a Certificate

cert.issuer = name
cert.sign key, OpenSSL::Digest.new('SHA1')

open 'certificate.pem', 'w' do |io| io.write cert.to_pem end

## Loading a Certificate
#Like a key, a cert can also be loaded from a file.

cert2 = OpenSSL::X509::Certificate.new File.read 'certificate.pem'

##Verifying a Certificate
#verify will return true when a certificate was signed with the give public key.

raise 'certificate can not be verified' unless cert2.verify key

##Certifate Authority
#A certificate authority is a trusted third party that allows you to verify the ownership of unknown certificates.
# The CA issues key signatures that indicate it trusts the user of that key. A user encountering the key can verify
# the signature by using the CA's public key.

#CA key
#Ca keys are valuable, so we encrypt and save it to disk and make sure it is not readable by other users.

ca_key = OpenSSL::PKey::RSA.new 2048
pass_phrase = 'my secure pass phrase goes here'

cipher = OpenSSL::Cipher.new 'aes-256-cbc'

open 'ca_key.pem', 'w', 0400 do |io|
    io.write ca_key.export(cipher, pass_phrase)
end

##CA Certificate
#A CA certificate is created the same way we created a certificate above, but with different extensions.

ca_name = OpenSSL::X509::Name.parse '/CN=ca/DC=example'
ca_cert = OpenSSL::X509::Certifate.new
ca_cert.serial = 0
ca_cert.version = 2
ca_cert.not_before = Time.now
ca_cert.not_after = Time.now + 86400

ca_cert.public_key = ca_key.public_key
ca_cert.subject = ca_name
ca_cert.issuer = ca_name

extension_factory = OpenSSL::X509::ExtensionFactory.new
extension_factory.subject_certificate = ca_cert
extension_factory.issuer_certificate = ca_cert

ca_cert.add_extension \
    extension_factory.create_extension('subjectKeyIdentifier', 'hash')

# This extension indicates the CA's key may be used as a CA.
ca_cert.add_extension \
    extension_factory.create_extension('basicConstraints', 'CA:TRUE', true)

# This extension indicates the CA's key may be used to verify signatures on both certificates and certificate revocations
ca_cert.add_extension \
    extension_factory.create_extension('keyUsage', 'cRLSign,keyCertSign', true)

#Root CA certificates are self-signed.

ca_cert.sign ca_key, OpenSSL::Digest.new('SHA1')

#The CA Certificate is saved to disk so it may be distributed to all the users of the keys this CA will sign
open 'ca_cert.pem', 'w' do |io|
    io.write ca_cert.to_pem
end

## Certificate Signing Request
#The CA signs keys throught a Certificate Signing Request(CSR). The CSR contains the information necessary to identify the key.

csr = OpenSSL::X509::Request.new
csr.version = 0
csr.subject = name
csr.public_key = key.public_key
csr.sign key, OpenSSL::Digest.new('SHA1')

# A CSR is saved to disk and send to the CA for signing.

open 'csr.pem', 'w' do |io|
    io.write csr.to_pem
end

# Creating a Certificate from a CSR
# Upon receiveing a CSR the CA will verify it before signing it. A minimal verification would be to check the CSR's signature.

csr = OpenSSL::X509::Request.new File.read 'csr.pem'

raise 'CSR can not be verified' unless csr.verify csr.public_key

## After verification a certificate is created, marked for various usages, signed with the CA Key and returned to the requester.

csr_cert = OpenSSL::X509::Certifate.new
csr_cert.serial = 0
csr_cert.version = 2
csr_cert.not_before = Time.now
csr_cert.not_after = Time.now + 600

csr_cert.subject = csr.subject
csr_cert.public_key = csr.public_key
csr_cert.issuer = ca_cert.subject

extension_factory = OpenSSL::X509::ExtensionFactory.new
extension_factory.subject_certificate = csr_cert
extension_factory.issuer_certificate = ca_cert

csr_cert.add_extension \
    extension_factory.create_extension('basicConstraints', 'CA:FALSE')
csr_cert.add_extension \
    extension_factory.create_extension('keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature')
csr_cert.add_extension \
    extension_factory.create_extension('subjectKeyIdentifier', 'hash')

csr_cert.sign ca_key, OpenSSL::Digest.new('SHA1')

open 'csr_cert.pem', 'w' do |io|
    io.write csr_cert.to_pem
end