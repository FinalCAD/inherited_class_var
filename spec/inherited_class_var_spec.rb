require 'spec_helper'

describe InheritedClassVar do
  let(:klass) { parent_class }

  describe "::inherited_class_hash" do
    subject { klass.send(:inherited_class_hash, :attributes) }
    it "calls ::inherited_class_var" do
      expect(klass).to receive(:inherited_class_var).with(:attributes, InheritedClassVar::Hash, {}).and_call_original
      subject
    end
  end

  describe "::inherited_class_var" do
    subject { klass.send(:inherited_class_var, :attributes, InheritedClassVar::Variable) }
    it "calls ::inherited_class_var" do
      expect(InheritedClassVar::Variable).to receive(:define_methods).with(:attributes, klass, {}).and_call_original
      subject
    end
  end

  describe '::inherited_custom_class' do
    let(:inherited_base_class) { Class.new { def self.name; "InheritedBaseClass" end } }
    subject { klass.send(:inherited_custom_class, :accessor_method_name, inherited_base_class) }

    it 'gives a name' do
      expect(subject.name).to eql 'ParentInheritedBaseClass'
    end
  end

  describe '::inherited_ancestors' do
    subject { child_class.send(:inherited_ancestors) }
    it 'returns the inherited ancestors' do
      expect(subject).to eql [child_class, parent_class, Mod2]
    end
  end
end
