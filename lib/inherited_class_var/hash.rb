module InheritedClassVar
  class Hash < Variable
    alias_method :merge, :change

    def default_value
      {}
    end

    def _change(hash1, hash2)
      hash1.deep_merge!(hash2)
    end
  end
end