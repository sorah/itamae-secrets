$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'tmpdir'
RSPEC_TEMP_PATH = Dir.mktmpdir

require 'itamae/secrets'
