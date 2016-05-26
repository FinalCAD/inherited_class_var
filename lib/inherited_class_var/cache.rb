module InheritedClassVar
  module Cache
    extend ActiveSupport::Concern

    class_methods do

      # Clears the cache for a variable (must be public)
      # @param variable_name [Symbol] variable_name to cache against
      def clear_class_cache(variable_name)
        instance_variable_set inherited_class_variable_name(variable_name), nil
      end

      protected
      # Memozies a inherited_class_variable_name
      # @param variable_name [Symbol] variable_name to cache against
      def class_cache(variable_name)
        #
        # equal to: (has @)inherited_class_variable_name ||= yield
        #
        cache_variable_name = inherited_class_variable_name(variable_name)
        instance_variable_get(cache_variable_name) || instance_variable_set(cache_variable_name, yield)
      end

      # Clears the cache for a variable and the same variable for all it's dependant descendants
      # @param variable_name [Symbol] variable_name to cache against
      def deep_clear_class_cache(variable_name)
        ([self] + descendants).each do |descendant|
          descendant.try(:clear_class_cache, variable_name)
        end
      end

      # @param variable_name [Symbol] variable_name to cache against
      # @return [String] the cache variable name for the cache
      def inherited_class_variable_name(variable_name)
        :"#{variable_name}_inherited_class_cache"
      end
    end
  end
end