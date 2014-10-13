require 'active_force'
require 'cancan'
require 'cancan_active_force_adapter'
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'
Dir["#{File.expand_path('../..', __FILE__)}/spec/support/**/*.rb"].each {|f| require f}

include TestClasses