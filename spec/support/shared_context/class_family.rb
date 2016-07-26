module Mod1; end
module Mod2; end

module ClassFamily
  extend RSpec::SharedContext

  let!(:grandparent_class) { Class.new { def self.name; "Grandparent" end } }
  let!(:parent_class) do
    Class.new(grandparent_class) do
      include Mod1
      include InheritedClassVar
      include Mod2

      def self.name; "Parent" end
    end
  end
  let!(:child_class) { Class.new(parent_class) { def self.name; "Child" end } }
end