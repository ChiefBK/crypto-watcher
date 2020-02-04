# frozen_string_literal: true

# EXTERNAL DEPENDENCIES

# Load environmental variables
require 'dotenv/load'

if ENV['DEVELOPMENT_MODE']
  # Use binding.pry debugger
  require 'pry'
  require 'pry-remote'
  require 'pry-nav'
end

require 'httparty' # for sending HTTP requests
require 'socket' # for TCP webserver
require 'digest/sha1' # to generate response key for websocket handshake

# INTERNAL DEPENDENCIES

# Require all files in ./lib
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }
