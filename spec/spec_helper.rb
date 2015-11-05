Bundler.require(:default, :test)
require 'inherited_class_var'

Coveralls.wear!

RSpec.configure do |c|
  c.run_all_when_everything_filtered = true
end
