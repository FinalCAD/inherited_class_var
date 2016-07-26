# InheritedClassVar [![Build Status](https://travis-ci.org/FinalCAD/inherited_class_var.svg?branch=master)](https://travis-ci.org/FinalCAD/inherited_class_var)[![Code Climate](https://codeclimate.com/github/FinalCAD/inherited_class_var.png)](https://codeclimate.com/github/FinalCAD/inherited_class_var)[![Dependency Status](https://gemnasium.com/FinalCAD/inherited_class_var.svg)](https://gemnasium.com/FinalCAD/inherited_class_var)[![Coverage Status](https://coveralls.io/repos/FinalCAD/inherited_class_var/badge.svg?branch=master&service=github)](https://coveralls.io/github/FinalCAD/inherited_class_var?branch=master)[![Gem Version](https://badge.fury.io/rb/inherited_class_var.svg)](http://badge.fury.io/rb/inherited_class_var)

Implement class variables that inherit from their ancestors. Such as a `Hash`:

```ruby
require 'inherited_class_var'

class Bird
  include InheritedClassVar
  inherited_class_hash :attributes #, shallow: false, reverse: false (default aoptions)
  
  def self.attribute(attribute_name, options={})
    attributes_object.merge(attribute_name.to_sym => options)
  end
  attribute :name, upcase: true
end

class Duck < Bird
  attribute :flying, default: false
end

Bird.attributes # => { name: upcase: true }
Duck.attributes # => { name: upcase: true, flying: false }
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'inherited_class_var'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install inherited_class_var

## Usage

You can also define your own variable types. This is the source for `Hash`:

```ruby
module InheritedClassVar
  class Hash < Variable
    alias_method :merge, :change

    def default_value
      {}
    end

    def _change(hash1, hash2)
      method = options[:shallow] ? :merge! : :deep_merge!
      block = options[:reverse] ? Proc.new {|key,left,right| left }  : Proc.new {|key,left,right| right }
      hash1.public_send(method, hash2, &block)
    end
  end
end

module InheritedClassVar
    def inherited_class_hash(variable_name, options={})
      inherited_class_var variable_name, InheritedClassVar::Hash, options
    end
end
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
