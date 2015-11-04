require 'spec_helper'

class Grandparent; end
module Child
  extend ActiveSupport::Concern
end
class Parent < Grandparent
  include Child
  include InheritedClassVar

  inherited_class_hash :inherited_hash

  inherited_class_hash :inherited_hash_with_dependencies, dependencies: %i[somethings]
  class << self
    protected
    def _somethings; inherited_hash_with_dependencies.to_json end
  end
end
class ClassWithFamily < Parent; end

class InheritedBaseClass; end

describe InheritedClassVar do
  describe 'class' do
    describe '::inherited_class_hash' do
      describe 'getter' do
        it 'calls inherited_class_var' do
          expect(Parent).to receive(:inherited_class_var).with(:@_inherited_hash, {}, :merge)
          Parent.inherited_hash
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
        end

        context 'with dependency' do
          it 'recalculates and caches the dependency' do
            expect(Parent.inherited_hash_with_dependencies).to eql({})
            expect(Parent.somethings).to eql('{}')

            Parent.merge_inherited_hash_with_dependencies(test1: 'test1')
            expect(Parent.somethings).to eql("{\"test1\":\"test1\"}")
            expect(Parent.somethings.object_id).to eql Parent.somethings.object_id
          end
        end
      end
    end

    describe '::inherited_ancestors' do
      subject { ClassWithFamily.send(:inherited_ancestors) }

      it 'returns the inherited ancestors' do
        expect(subject).to eql [ClassWithFamily, Parent, InvalidOptions]
      end
    end

    describe '::inherited_custom_class' do
      let(:klass) { Parent }
      subject { klass.send(:inherited_custom_class, :does_not_exist, InheritedBaseClass) }

      it 'gives a name' do
        expect(subject.name).to eql 'ParentInheritedBaseClass'
      end
    end

    context 'with deep_inherited_class_var set' do
      let(:variable_name) { :@inherited_class_var }
      def inherited_class_var
        ClassWithFamily.send(:inherited_class_var, variable_name, [], :+)
      end

      before do
        [Grandparent, Parent, Child, ClassWithFamily].each do |klass|
          klass.instance_variable_set(variable_name, [klass.to_s])
        end
      end

      describe '::inherited_class_var' do
        subject { inherited_class_var }

        it 'returns a class variable merged across ancestors until #{described_class}' do
          expect(subject).to eql %w[Parent ClassWithFamily]
        end

        it 'caches the result' do
          expect(inherited_class_var.object_id).to eql inherited_class_var.object_id
        end
      end

      describe '::clear_class_cache' do
        subject { ClassWithFamily.clear_class_cache(variable_name) }

        it 'clears the cache' do
          value = inherited_class_var
          expect(value.object_id).to eql inherited_class_var.object_id
          subject
          expect(value.object_id).to_not eql inherited_class_var.object_id
        end
      end

      describe '::deep_clear_class_cache' do
        subject { Parent.send(:deep_clear_class_cache, variable_name) }

        def parent_inherited_class_var
          Parent.send(:inherited_class_var, variable_name, [], :+)
        end

        it 'clears the cache of self class' do
          value = parent_inherited_class_var
          expect(value.object_id).to eql parent_inherited_class_var.object_id
          subject
          expect(value.object_id).to_not eql parent_inherited_class_var.object_id
        end

        it 'clears the cache of children class' do
          value = inherited_class_var
          expect(value.object_id).to eql inherited_class_var.object_id
          subject
          expect(value.object_id).to_not eql inherited_class_var.object_id
        end
      end
    end
  end
end
