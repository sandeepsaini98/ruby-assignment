# Certificate Authority (CA) Certificate and Client Certificate Generator

This repository contains the code and instructions for generating a Certificate Authority (CA) certificate and client certificate using OpenSSL and Ruby.

## Getting Started

1. Clone this repository to your local machine.

2. Install the required gems:
   ```bash
   gem install sinatra rest-client openssl json
3. Run the ca_generator.rb script to generate the CA certificate:
   ```bash
    ruby ca_generator.rb
4. Run the certificate_generator.rb script to generate the client certificate:
   ```
   ruby certificate_generator.rb

## Start the web server:

1. Run the web_server.rb script in the background:
    ```
    ruby web_server.rb

## To verify the expiration date of the client certificate:

1. Run the test_connection.rb
    ```
    ruby test_connection.rb
    ```
    This script will make a GET request to the /certificate endpoint of the web server and verify the expiration date of the client certificate. If the expiration date is valid, the script will print a message to the console indicating that the certificate is valid. Otherwise, the script will print a message to the console indicating that the certificate has expired.


## If you have to run all the above process at once, you can run `rake test` to run all the task 

## Documentation:

- OpenSSL:    https://www.openssl.org/ || https://docs.ruby-lang.org/en/3.2/OpenSSL.html
- Ruby:       https://www.ruby-lang.org/en/
- RESTClient: http://restclient.net/

## Contributing:
    
    If you have any suggestions or bug reports, please feel free to open an issue on GitHub.


