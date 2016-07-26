require 'active_support/all'

require 'inherited_class_var/version'
require 'inherited_class_var/variable'
require 'inherited_class_var/hash'

module InheritedClassVar
  extend ActiveSupport::Concern

  class_methods do
    protected

    # @param variable_name [Symbol] class variable name
    # @param options [Hash] see InheritedClassVar::Hash
    def inherited_class_hash(variable_name, options={})
      inherited_class_var InheritedClassVar::Hash, variable_name, options
    end

    # @param variable_class [Class] a InheritedClassVar::Variable class
    # @param variable_name [Symbol] class variable name
    # @param options [Hash] see the variable_class
    def inherited_class_var(variable_class, variable_name, options={})
      variable_class.define_methods(self, variable_name, options)
    end

    # @param accessor_method_name [Symbol] method to access the inherited_custom_class
    # @param base_parent_class [Class] class that the custom class inherits from if there's no parent
    # @return [Class] a custom class with the inheritance following self. for example:
    #
    # grandparent -> parent -> self
    #
    # we want self::inherited_custom_class to inherit from inherited_custom_class of all the ancestors
    #
    # grandparent has inherited_custom_class, but parent, doesn't.
    #
    # then: base_parent_class -> grandparent::inherited_custom_class -> self::inherited_custom_class
    def inherited_custom_class(accessor_method_name, base_parent_class)
      parent_class = inherited_ancestors[1..-1].find do |klass|
        klass.respond_to?(accessor_method_name)
      end.try(accessor_method_name)
      parent_class ||= base_parent_class

      klass = Class.new(parent_class)
      klass.send(:define_singleton_method, :name, &eval("-> { \"#{name}#{base_parent_class.name.demodulize}\" }"))
      klass
    end

    public
    # @param included_module [Module] module to search for
    # @return [Array<Module>] inherited_ancestors of included_module (including self)
    def inherited_ancestors(included_module=InheritedClassVar)
      included_model_index = ancestors.index(included_module)
      included_model_index == 0 ? [included_module] : (ancestors[0..(included_model_index - 1)])
    end
  end
end
