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

require 'bigdecimal'



# INTERNAL DEPENDENCIES

# Require all files in ./lib
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }
