require 'inherited_class_var'
require 'bundler/setup'
require 'coveralls'

begin
  require 'pry'
rescue LoadError
end

Coveralls.wear!

RSpec.configure do |c|
  c.run_all_when_everything_filtered = true
end
