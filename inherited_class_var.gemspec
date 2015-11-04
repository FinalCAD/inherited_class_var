require_relative 'lib/inherited_class_var/version'

Gem::Specification.new do |spec|
  spec.name          = 'inherited_class_var'
  spec.version       = InheritedClassVar::VERSION
  spec.authors       = ['Steve Chung', 'Joel AZEMAR']
  spec.email         = ['hello@stevenchung.ca','joel.azemar@gmail.com']

  spec.summary       = %q{Let inherited class var}
  spec.description   = %q{Let inherited class var to authorize inheritance}
  spec.homepage      = 'https://github.com/FinalCAD/inherited_class_var'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = 'TODO: Set to 'http://mygemserver.com''
  # else
  #   raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport',       '~> 4.2'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'rspec',   '~> 3.3'
end
