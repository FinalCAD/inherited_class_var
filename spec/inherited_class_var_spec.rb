require 'spec_helper'

class Grandparent; end
module Mod; end

class Parent < Grandparent
  include Mod
  include InheritedClassVar

  inherited_class_hash :inherited_hash
end
class Child < Parent; end

describe InheritedClassVar do
  describe '::inherited_class_hash' do
    describe 'getter' do
      it 'calls inherited_class_var' do
        expect(Parent).to receive(:inherited_class_var).with(:@_inherited_hash, {}, :merge)
        Parent.inherited_hash
      end
    end

    describe "raw getter" do
      it 'calls inherited_class_var' do
        expect(Parent).to receive(:class_var).with(:@_inherited_hash, {}).and_call_original
        Parent.raw_inherited_hash
      end
    end

    describe 'merger' do
      it 'continuously merges the new variable value' do
        expect(Parent.inherited_hash).to eql({})

        Parent.merge_inherited_hash(test1: 'test1')
        expect(Parent.inherited_hash).to eql(test1: 'test1')
        Parent.merge_inherited_hash(test2: 'test2')
        expect(Parent.inherited_hash).to eql(test1: 'test1', test2: 'test2')

        expect(Parent.inherited_hash.object_id).to eql Parent.inherited_hash.object_id
        expect(Child.inherited_hash).to eql(test1: 'test1', test2: 'test2')

        expect(Parent.raw_inherited_hash).to eql(test1: 'test1', test2: 'test2')
        expect(Child.raw_inherited_hash).to eql({})
      end
    end
  end

  describe '::inherited_custom_class' do
    let(:klass) { Parent }
    let(:inherited_base_class) { Class.new { def self.name; "InheritedBaseClass" end } }
    subject { klass.send(:inherited_custom_class, :does_not_exist, inherited_base_class) }

    it 'gives a name' do
      expect(subject.name).to eql 'ParentInheritedBaseClass'
    end
  end

  describe '::inherited_ancestors' do
    it 'returns the inherited ancestors' do
      expect(Child.send(:inherited_ancestors)).to eql [Child, Parent]
    end
  end

  context 'with deep_inherited_class_var set' do
    let(:variable_name) { :@inherited_class_var }
    def inherited_class_var; Child.send(:inherited_class_var, variable_name, [], :+) end

    before do
      [Grandparent, Parent, Mod, Child].each { |klass| klass.instance_variable_set(variable_name, [klass.to_s]) }
    end

    describe "::class_var" do
      it "returns the class variable" do
        [Parent, Child].each do |klass|
          expect(klass.send(:class_var, variable_name, [])).to eql [klass.to_s]
        end

        [Grandparent, Mod].each do |klass|
          expect { klass.send(:class_var, variable_name, []) }.to raise_error(NoMethodError)
        end
      end
    end

    describe '::inherited_class_var' do
      it 'returns a class variable merged across ancestors until #{described_class}' do
        expect(inherited_class_var).to eql %w[Child Parent]
      end

      it 'caches the result' do
        expect(inherited_class_var.object_id).to eql inherited_class_var.object_id
      end
    end

    describe '::clear_class_cache' do
      it 'clears the cache' do
        value = inherited_class_var
        expect { Child.clear_class_cache(variable_name) }.to change {
          value.object_id == inherited_class_var.object_id
        }.from(true).to(false)
      end
    end

    describe '::deep_clear_class_cache' do
      subject { Parent.send(:deep_clear_class_cache, variable_name) }

      def parent_inherited_class_var
        Parent.send(:inherited_class_var, variable_name, [], :+)
      end

      it 'clears the cache of self class' do
        value = parent_inherited_class_var
        expect { subject }.to change {
          value.object_id == parent_inherited_class_var.object_id
        }.from(true).to(false)
      end

      it 'clears the cache of Child class' do
        value = inherited_class_var
        expect { subject }.to change {
          value.object_id == inherited_class_var.object_id
        }.from(true).to(false)
      end
    end
  end
end
