require 'active_support/all'

require 'inherited_class_var/version'
require 'inherited_class_var/cache'

module InheritedClassVar
  extend ActiveSupport::Concern

  include Cache

  class_methods do
    protected

    #
    # Easy Open API
    #

    # @param variable_name [Symbol] class variable name
    # @option options [Array] :dependencies array of dependent method names
    def inherited_class_hash(variable_name)
      hidden_variable_name = hidden_variable_name(variable_name)

      define_singleton_method variable_name do
        inherited_class_var(hidden_variable_name, {}, :deep_merge)
      end

      define_singleton_method :"raw_#{variable_name}" do
        class_var(hidden_variable_name, {})
      end

      define_singleton_method :"merge_#{variable_name}" do |merge_value|
        deep_clear_class_cache(hidden_variable_name)
        public_send(:"raw_#{variable_name}").merge!(merge_value)
      end
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
      # how else can i get the current scopes name...
      klass.send(:define_singleton_method, :name, &eval("-> { \"#{name}#{base_parent_class.name.demodulize}\" }"))
      klass
    end

    #
    # Helpers to make different types of inherited class variables
    #

    # @param variable_name [Symbol] class variable name based on
    # @return [Symbol] the hidden variable name for class variable
    def hidden_variable_name(variable_name)
      :"@_#{variable_name}"
    end

    # @param variable_name [Symbol] class variable name
    # @param default_value [Object] default value of the class variable
    # @return [Object] a class variable of the specific class without taking into account inheritance
    def class_var(variable_name, default_value)
      instance_variable_get(variable_name) || instance_variable_set(variable_name, default_value)
    end

    # @param variable_name [Symbol] class variable name (recommend :@_variable_name)
    # @param default_value [Object] default value of the class variable
    # @param merge_method [Symbol] method to merge values of the class variable
    # @return [Object] a class variable merged across ancestors until inherited_class_module
    def inherited_class_var(variable_name, default_value, merge_method)
      class_cache(variable_name) do
        inherited_ancestors.map { |ancestor| ancestor.class_var(variable_name, default_value) }.reduce(default_value, merge_method)
      end
    end

    #
    # More Helpers
    #

    # @param included_module [Module] module to search for
    # @return [Array<Module>] inherited_ancestors of included_module (including self)
    def inherited_ancestors(included_module=InheritedClassVar)
      included_model_index = ancestors.index(included_module)
      included_model_index == 0 ? [included_module] : (ancestors[0..(included_model_index - 1)])
    end
  end
end
