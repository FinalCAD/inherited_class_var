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