Bundler.require(:default, :test)
Coveralls.wear!

require 'inherited_class_var'

Dir[Dir.pwd + '/spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |c|
  c.include ClassFamily
  c.include WithThisThenContext
  c.run_all_when_everything_filtered = true
end