require_relative 'lib/inherited_class_var/version'

Gem::Specification.new do |spec|
  spec.name          = 'inherited_class_var'
  spec.version       = InheritedClassVar::VERSION
  spec.authors       = ['Steve Chung', 'Joel AZEMAR']
  spec.email         = ['hello@stevenchung.ca','joel.azemar@gmail.com']

  spec.summary       = %q{Implement class variables that inherit from their ancestors.}
  spec.description   = %q{Implement class variables that inherit from their ancestors.}
  spec.homepage      = 'https://github.com/FinalCAD/inherited_class_var'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 4.2'
end
