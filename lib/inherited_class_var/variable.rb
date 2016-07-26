module InheritedClassVar
  class Variable
    attr_reader :name, :klass

    def initialize(name, klass)
      @name = name
      @klass = klass
    end

    def object_method_name
      self.class.object_method_name(name)
    end

    def default_value
      raise NotImplementedError
    end

    def raw_value
      @raw_value ||= default_value
    end

    def value
      @value ||= klass.inherited_ancestors
        .map { |ancestor| ancestor.try(object_method_name).try(:raw_value) }
        .compact
        .reverse
        .reduce(default_value, &self.class.method(:reduce))
    end

    def change(other_value)
      notify_change
      self.class.change(raw_value, other_value)
    end

    def notify_change
      ([klass] + klass.descendants).each do |descendant|
        descendant.try(object_method_name).try(:clear_memoized_value)
      end
    end

    def clear_memoized_value
      @value = nil if @value
    end

    class << self
      def object_method_name(name)
        :"#{name}_object"
      end

      def define_methods(name, klass)
        variable_class = self
        object_method_name = object_method_name(name)

        klass.send :define_singleton_method, object_method_name do
          instance_variable_name = :"@#{object_method_name}"
          instance_variable_get(instance_variable_name) || instance_variable_set(instance_variable_name, variable_class.new(name, self))
        end
        klass.send(:define_singleton_method, name) { public_send(object_method_name).value }
      end

      def change(value1, value2)
        raise NotImplementedError
      end
      def reduce(*args); change(*args) end
    end
  end
end