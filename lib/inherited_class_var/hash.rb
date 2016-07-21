module InheritedClassVar
  class Hash < Variable
    def raw_value
      @raw_value ||= {}
    end

    def value
      @value ||= super({}, &self.class.method(:merge))
    end

    def merge(merge_value)
      super
      self.class.merge(raw_value, merge_value)
    end

    class << self
      def merge(hash1, hash2)
        hash1.deep_merge!(hash2) {|key,left,right| left } # a reverse_deep_merge! implementation, this will keep the hash1's key order
      end
    end
  end
end