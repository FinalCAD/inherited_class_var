require 'spec_helper'

describe InheritedClassVar::Variable do
  let(:klass) { parent_class }
  let(:attribute_class) do
    Class.new(described_class) do
      def default_value; [] end
      def raw_value; klass.name end
      def self.change(array, class_name); array << class_name end
    end
  end

  describe "instance" do
    let(:instance) { attribute_class.new(:attributes, klass) }
    before { attribute_class.define_methods(:attributes, parent_class) }

    describe "#object_method_name" do
      subject { instance.object_method_name }
      it "works" do
        expect(subject).to eql :attributes_object
      end
    end

    describe "#default_value" do
      subject { instance.default_value }
      let(:attribute_class) { described_class }
      it "raises error" do
        expect { subject }.to raise_error(NotImplementedError)
      end
    end

    describe "#raw_value" do
      subject { instance.raw_value }
      let(:attribute_class) { described_class }
      it "memoizes the default_value" do
        allow(instance).to receive(:default_value) { "waka" }
        expect(instance.default_value.object_id).to_not eql instance.default_value.object_id
        expect(subject).to eql "waka"
        expect(subject.object_id).to eql instance.raw_value.object_id
      end
    end

    describe "#value" do
      subject { instance.value }

      it "returns parent_class name memoized" do
        expect(subject).to eql %w[Parent]
        expect(subject.object_id).to eql instance.value.object_id
      end

      context "for the child" do
        let(:klass) { child_class }
        it "returns the Parent THEN Child" do
          expect(subject).to eql %w[Parent Child]
        end
      end
    end

    describe "#change" do
      subject { instance.change("other_value") }
      it "calls notify_change" do
        expect(instance).to receive(:notify_change)
        expect(attribute_class).to receive(:change).with("Parent", "other_value")
        subject
      end
    end

    describe "#notify_change" do
      subject { instance.notify_change }
      it "clears the memoized value of itself and descendants" do
        [parent_class, child_class].each do |klass|
          expect(klass.attributes_object).to receive(:clear_memoized_value)
        end
        subject
      end
    end

    describe "clear_memoized_value" do
      subject { instance.clear_memoized_value }
      it "sets the memoized value to nil" do
        instance.value
        expect(instance.instance_variable_get(:@value)).to_not eql nil
        subject
        expect(instance.instance_variable_get(:@value)).to eql nil
        instance.value
        expect(instance.instance_variable_get(:@value)).to_not eql nil
      end
    end
  end

  describe "class" do
    describe "::object_method_name" do
      subject { attribute_class.object_method_name(:attributes) }
      it "works" do
        expect(subject).to eql :attributes_object
      end
    end

    describe "::define_methods" do
      subject { attribute_class.define_methods(:attributes, klass) }

      it "adds an object_method and a getter" do
        subject
        attribute = attribute_class.new(:attributes, klass)
        %i[class name klass].each do |method|
          expect(klass.attributes_object.public_send(method)).to eql attribute.public_send(method)
        end
        expect(klass.attributes).to eql attribute.value
      end
    end

    describe "::change" do
      subject { attribute_class.change(nil, nil) }
      let(:attribute_class) { described_class }
      it "raises error" do
        expect { subject }.to raise_error(NotImplementedError)
      end
    end

    describe "::reduce" do
      subject { attribute_class.reduce("a", "b") }
      it "calls ::change with the same args" do
        expect(attribute_class).to receive(:change).with("a", "b")
        subject
      end
    end
  end
end