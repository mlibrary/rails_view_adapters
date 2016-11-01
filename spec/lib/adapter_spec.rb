# frozen_string_literal: true
require "spec_helper"

module RailsViewAdapters
  describe Adapter do
    describe "::define" do
      it "defines a new class" do
        Adapter.define(:new_test_adapter) {}
        expect do
          Object.const_get("NewTestAdapter")
        end.to_not raise_error
      end

      it "sets the constant equal to the created adapter" do
        spy = double(:spy)
        allow(Adapter).to receive(:adapter_from_map).and_return(spy)
        Adapter.define(:even_newer) {}
        expect(EvenNewer).to eql(spy)
      end
    end

    describe "::adapter_from_map" do
      let(:map) do
        double(:map,
          model_fields: [:m1, :m2],
          public_fields: [:p1, :p2],
          simple_maps: [[:m1, :p1]],
          to_maps: [[:m2, double(:proc1)]],
          from_maps: [[:p2, double(:proc2)]])
      end
      let(:adapter) { Adapter.adapter_from_map(map) }
      it "returns a new class" do
        expect(adapter).to be_a(Class)
      end
      it "inherits from AdapterBase" do
        expect(adapter).to be <= AdapterBase
      end
      [:model_fields, :public_fields, :simple_maps, :to_maps, :from_maps].each do |field|
        it "adds the ::#{field} method" do
          expect(adapter.public_send(field)).to eql(map.public_send(field))
        end
      end
    end
  end
end
