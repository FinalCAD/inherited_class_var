module InheritedClassVar
  class Variable
    attr_reader :name, :klass

    def initialize(name, klass)
      @name = name
      @klass = klass
    end

    def define_methods
      object_method_name = self.object_method_name
      klass.send(:define_singleton_method, name) { public_send(object_method_name).value }
      klass.send(:define_singleton_method, raw_method_name) { public_send(object_method_name).raw_value }
      klass.send(:define_singleton_method, merge_method_name) { |merge_value| public_send(object_method_name).merge(merge_value) }
    end

    def object_method_name
      self.class.object_method_name(name)
    end

    def raw_method_name
      :"raw_#{name}"
    end

    def merge_method_name
      :"merge_#{name}"
    end

    def value(*reduce_args, &block)
      klass.inherited_ancestors
        .map { |ancestor| ancestor.try(raw_method_name) }
        .compact
        .reverse
        .reduce(*reduce_args, &block)
    end

    def merge(other_value)
      notify_change
    end

    def clear_memoized_value
      @value = nil if @value
    end

    def notify_change
      ([klass] + klass.descendants).each do |descendant|
        descendant.try(object_method_name).try(:clear_memoized_value)
      end
    end

    class << self
      def object_method_name(name)
        :"#{name}_object"
      end
    end
  end
end