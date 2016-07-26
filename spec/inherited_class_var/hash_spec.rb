require 'spec_helper'

describe InheritedClassVar::Hash do
  let(:klass) { parent_class }
  let(:instance) { described_class.new(:attributes, klass) }

  before do
    described_class.define_methods(:attributes, parent_class)
  end

  describe "#value" do
    it "takes the value of the ancestors" do
      parent_class.attributes_object.change(a: { test1: 1 })
      child_class.attributes_object.change(b: 3, a: { test1: 2 })
      expect(parent_class.attributes_object.raw_value).to eql(a: { test1: 1 })
      expect(child_class.attributes_object.raw_value).to eql(a: { test1: 2 }, b: 3)
      expect(parent_class.attributes_object.value).to eql(a: { test1: 1 })
      expect(child_class.attributes_object.value).to eql(a: { test1: 2 }, b: 3)

      parent_class.attributes_object.change(c: 4)
      expect(parent_class.attributes_object.raw_value).to eql(a: { test1: 1 }, c: 4)
      expect(child_class.attributes_object.raw_value).to eql(a: { test1: 2 }, b: 3)
      expect(parent_class.attributes_object.value).to eql(a: { test1: 1 }, c: 4)
      expect(child_class.attributes_object.value).to eql(a: { test1: 2 }, b: 3, c: 4)
    end
  end

  describe "#merge" do
    it "is alias of #change" do
      expect(instance.method(:merge)).to eql instance.method(:change)
    end
  end

  describe "#default_value" do
    subject { instance.default_value }
    it "is an empty hash" do
      expect(subject).to eql({})
    end
  end

  describe "#_change" do
    subject { hashes.reduce({}, &instance.method(:_change)) }
    let(:hashes) { [{ test1: 'test1' }, { test2: 'test2' }] }

    it "continuously merges" do
      expect(subject).to eql(test1: 'test1', test2: 'test2')
    end

    context 'with conflicting keys' do
      let(:hashes) { [{ test1: 'a' }, { test1: 'b' }] }
      it "prioritizes the second hash" do
        expect(subject).to eql(test1: 'b')
      end
    end

    context "with many keys" do
      let(:hashes) { [{ a: 1, b: 2, c: 3 }, { b: 10, d: 4 }] }
      it "makes lefts-most keys a priority" do
        expect(subject.keys).to eql %i[a b c d]
      end
    end

    context "with nested hashes" do
      let(:hashes) { [ { a: { a1: 'a1'} }, { a: { a2: 'a2'} } ] }

      it "does a deep merge" do
        expect(subject).to eql(a: { a1: 'a1', a2: 'a2'})
      end
    end
  end
end