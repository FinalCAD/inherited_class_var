require 'spec_helper'

module Mod1; end
module Mod2; end

describe InheritedClassVar do
  let(:grandparent_class) { Class.new { def self.name; "grandparent_class" end } }
  let(:parent_class) do
    Class.new(grandparent_class) do
      include Mod1
      include InheritedClassVar
      include Mod2

      inherited_class_hash :inherited_hash

      def self.name; "Parent" end
    end
  end
  let(:child_class) { Class.new(parent_class) { def self.name; "Child" end } }

  describe '::inherited_class_hash' do
    describe 'getter', skip: true do
      it 'calls inherited_class_var' do
        expect(parent_class).to receive(:inherited_class_var).with(:@_inherited_hash, {})
        parent_class.inherited_hash
      end
    end

    describe "raw getter", skip: true do
      it 'calls inherited_class_var' do
        expect(parent_class).to receive(:class_var).with(:@_inherited_hash, {}).and_call_original
        parent_class.raw_inherited_hash
      end
    end

    describe 'merger' do
      it 'continuously merges the new variable value' do
        expect(parent_class.inherited_hash).to eql({})

        parent_class.merge_inherited_hash(test1: 'test1')
        expect(parent_class.inherited_hash).to eql(test1: 'test1')
        parent_class.merge_inherited_hash(test2: 'test2')
        expect(parent_class.inherited_hash).to eql(test1: 'test1', test2: 'test2')

        expect(parent_class.inherited_hash.object_id).to eql parent_class.inherited_hash.object_id
        expect(child_class.inherited_hash).to eql(test1: 'test1', test2: 'test2')

        expect(parent_class.raw_inherited_hash).to eql(test1: 'test1', test2: 'test2')
        expect(child_class.raw_inherited_hash).to eql({})
      end

      it "the order of the parent's keys takes priority" do
        parent_class.merge_inherited_hash(a: 1, b: 2, c: 3)
        parent_class.merge_inherited_hash(b: 10, d: 4)

        expect(parent_class.inherited_hash.keys).to eql %i[a b c d]
        expect(parent_class.raw_inherited_hash.keys).to eql %i[a b c d]
      end

      it "does a deep merge" do
        parent_class.merge_inherited_hash(a: { a1: 'a1'})
        parent_class.merge_inherited_hash(a: { a2: 'a2'})

        expect(parent_class.inherited_hash).to eql(a: { a1: 'a1', a2: 'a2'})
        expect(parent_class.raw_inherited_hash).to eql(a: { a1: 'a1', a2: 'a2'})
      end

      context "between children" do
        it "the order of the parent's keys takes priority" do
          parent_class.merge_inherited_hash(a: 1, b: 2, c: 3)
          child_class.merge_inherited_hash(b: 10, d: 4)

          expect(parent_class.inherited_hash.keys).to eql %i[a b c]
          expect(parent_class.raw_inherited_hash.keys).to eql %i[a b c]

          expect(child_class.inherited_hash.keys).to eql %i[a b c d]
          expect(child_class.raw_inherited_hash.keys).to eql %i[b d]
        end

        it "does a deep merge" do
          parent_class.merge_inherited_hash(a: { a1: 'a1'})
          child_class.merge_inherited_hash(a: { a2: 'a2'})

          expect(parent_class.inherited_hash).to eql(a: { a1: 'a1'})
          expect(child_class.inherited_hash).to eql(a: { a1: 'a1', a2: 'a2'})

          expect(parent_class.raw_inherited_hash).to eql(a: { a1: 'a1'})
          expect(child_class.raw_inherited_hash).to eql(a: { a2: 'a2'})
        end
      end
    end
  end

  describe '::inherited_custom_class' do
    let(:klass) { parent_class }
    let(:inherited_base_class) { Class.new { def self.name; "InheritedBaseClass" end } }
    subject { klass.send(:inherited_custom_class, :does_not_exist, inherited_base_class) }

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

  context 'with deep_inherited_class_var set' do
    let(:variable_name) { :@inherited_class_var }
    let(:args) { [variable_name, [], :+] }
    def parent_inherited_class_var; parent_class.send(:inherited_class_var, *args) end
    def child_inherited_class_var; child_class.send(:inherited_class_var, *args) end

    before do
      [grandparent_class, parent_class, Mod1, child_class].each { |klass| klass.instance_variable_set(variable_name, [klass.name]) }
    end

    describe "::class_var" do
      subject { parent_class.send(:class_var, variable_name, []) }

      it "returns the class variable" do
        expect(subject).to eql [parent_class.name]
      end
    end

    describe '::inherited_class_var' do
      subject { child_inherited_class_var }

      it "returns a class variable merged across ancestors until #{described_class}" do
        expect(subject).to eql %w[Parent Child]
      end

      it 'caches the result' do
        expect(subject.object_id).to eql child_inherited_class_var.object_id
      end

      context "with a block" do
        subject { child_class.send(:inherited_class_var, variable_name, []) { |array, to_merge| array + to_merge } }
        it "returns a class variable merged across ancestors until #{described_class}" do
          expect(subject).to eql %w[Parent Child]
        end
      end
    end

    describe '::clear_class_cache' do
      subject { child_class.clear_class_cache(variable_name) }

      it 'clears the cache' do
        value = child_inherited_class_var
        expect { subject }.to change { value.object_id == child_inherited_class_var.object_id }.from(true).to(false)
      end
    end

    describe '::deep_clear_class_cache' do
      subject { parent_class.send(:deep_clear_class_cache, variable_name) }

      it 'clears the cache of self class' do
        value = parent_inherited_class_var
        expect { subject }.to change { value.object_id == parent_inherited_class_var.object_id  }.from(true).to(false)
      end

      it 'clears the cache of child class' do
        value = child_inherited_class_var
        expect { subject }.to change { value.object_id == child_inherited_class_var.object_id }.from(true).to(false)
      end
    end
  end
end
