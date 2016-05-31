Bundler.require(:default, :test)
Coveralls.wear!

require 'inherited_class_var'

RSpec.configure do |c|
  c.run_all_when_everything_filtered = true
end