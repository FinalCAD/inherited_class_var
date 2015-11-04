Bundler.require(:default, :test)
Coveralls.wear!

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'inherited_class_var'

RSpec.configure do |c|
  c.run_all_when_everything_filtered = true
end