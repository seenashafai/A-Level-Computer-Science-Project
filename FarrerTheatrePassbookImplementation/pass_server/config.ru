#
#  config.ru
#  Pass Server reference implementation
#
#  Copyright (c) 2012 Apple, Inc. All rights reserved.
#

require './pass_server'

# Used to implement HTTP PUT and DELETE with HTTP POST and _method
use Rack::MethodOverride

# Pass Server Settings
PassServer.set :hostname, "rogue01.local"
PassServer.set :port, 6789
PassServer.set :pass_type_identifier, "pass.com.theatrePass.A-Level-CompSciProj"
PassServer.set :team_identifier, "AZQME83VC4"

# Ask user for certificate password
puts "No password, no problem...: "
password_input = gets.chomp
PassServer.set :certificate_password, password_input

run PassServer
