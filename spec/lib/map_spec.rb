# frozen_string_literal: true
require "spec_helper"

module RailsViewAdapters

  class TestMap < Map
    def to_hash
      {
        model_fields: model_fields,
        public_fields: public_fields,
        simple_maps: simple_maps,
        to_maps: to_maps,
        from_maps: from_maps
      }
    end
  end

  describe Map do
    let(:map) { TestMap.new }
    let(:bare_hash) do
      {
        model_fields: [],
        public_fields: [],
        simple_maps: [],
        to_maps: [],
        from_maps: []
      }
    end

    describe "#add_model_field" do
      let(:model_field) { :test123 }
      it "adds the model field" do
        map.add_model_field(model_field)
        expect(map.to_hash).to eql(bare_hash.merge(model_fields: [model_field]))
      end
      it "returns self" do
        expect(map.add_model_field(model_field)).to be(map)
      end
    end

    describe "#add_public_field" do
      let(:public_field) { :test123 }
      it "adds the model field" do
        map.add_public_field(public_field)
        expect(map.to_hash).to eql(bare_hash.merge(public_fields: [public_field]))
      end
      it "returns self" do
        expect(map.add_public_field(public_field)).to be(map)
      end
    end

    describe "#add_simple_map" do
      let(:public_field) { :pub }
      let(:model_field) { :mod }
      it "adds the simple mapping" do
        map.add_simple_map(model_field, public_field)
        expect(map.to_hash).to eql(bare_hash.merge(
          public_fields: [public_field],
          model_fields: [model_field],
          simple_maps: [[model_field, public_field]]
        ))
      end
      it "returns self" do
        expect(map.add_simple_map(model_field, public_field)).to be(map)
      end
    end

    describe "#add_to_map" do
      let(:model_field) { :mod }
      let(:process) { proc {|v| v + 37 } }
      it "adds the mapping" do
        map.add_to_map(model_field, &process)
        expect(map.to_hash).to eql(bare_hash.merge(
          model_fields: [model_field],
          to_maps: [[model_field, process]]
        ))
      end
      it "returns self" do
        expect(map.add_to_map(model_field, &process)).to be(map)
      end
    end

    describe "#add_from_map" do
      let(:public_field) { :pub }
      let(:process) { proc {|v| v + 37 } }
      it "adds the mapping" do
        map.add_from_map(public_field, &process)
        expect(map.to_hash).to eql(bare_hash.merge(
          public_fields: [public_field],
          from_maps: [[public_field, process]]
        ))
      end
      it "returns self" do
        expect(map.add_from_map(public_field, &process)).to be(map)
      end
    end
  end

end
