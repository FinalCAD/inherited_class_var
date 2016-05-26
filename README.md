# InheritedClassVar

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/inherited_class_var`. To experiment with that code, run `bin/console` for an interactive prompt.

[![Code Climate](https://codeclimate.com/github/FinalCAD/inherited_class_var.png)](https://codeclimate.com/github/FinalCAD/inherited_class_var)

[![Dependency Status](https://gemnasium.com/FinalCAD/inherited_class_var.svg)](https://gemnasium.com/FinalCAD/inherited_class_var)

[![Build Status](https://travis-ci.org/FinalCAD/inherited_class_var.svg?branch=master)](https://travis-ci.org/FinalCAD/inherited_class_var) (Travis CI)

[![Coverage Status](https://coveralls.io/repos/FinalCAD/inherited_class_var/badge.svg?branch=master&service=github)](https://coveralls.io/github/FinalCAD/inherited_class_var?branch=master)

[![Gem Version](https://badge.fury.io/rb/inherited_class_var.svg)](http://badge.fury.io/rb/inherited_class_var)


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

You can follow this example, if you want to create Models with columns information and these informations still available after inheritance

Create a Model module with `inherited_class_var`

```
require 'inherited_class_var'

module Model
  extend ActiveSupport::Concern

  included do
    include InheritedClassVar
    inherited_class_hash :columns
  end

  module ClassMethods

    protected

    def column(column_name, options={})
      merge_columns(column_name.to_sym => options)
    end
  end
end
```

`merge_columns` it's bring by `inherited_class_var`

```
class ModelBase
  include Model

  column :id, type: Integer
end
```

Gives
```
ModelBase.columns # => {:id=>{:type=>Integer}}
```

```
class UserModel < ModelBase

  column :name, type: String
end
```

Gives
```
UserModel.columns # => {:id=>{:type=>Integer}, :name=>{:type=>String}}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/inherited_class_var. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
