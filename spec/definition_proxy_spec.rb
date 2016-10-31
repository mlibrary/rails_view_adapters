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

  describe DefinitionProxy do
    let(:proxy) { described_class.new(TestMap.new) }
    let(:bare_hash) do
      {
        model_fields: [],
        public_fields: [],
        simple_maps: [],
        to_maps: [],
        from_maps: []
      }
    end

    describe "#map_simple" do
      let(:model_field) { :mod }
      let(:public_field) { :pub }
      it "creates the correct mapping" do
        proxy.map_simple(model_field, public_field)
        expect(proxy.map.to_hash).to eql(bare_hash.merge({
          public_fields: [public_field],
          model_fields: [model_field],
          simple_maps: [[model_field, public_field]]
        }))
      end
    end

    describe "#map_to_public" do
      let(:model_field) { :mod }
      let(:extra_fields) { [:one, :two] }
      let(:process) { Proc.new {|v| {one: v+1, two: v+2}} }
      it "creates the correct mapping" do
        proxy.map_to_public(model_field, extra_fields, &process)
        expect(proxy.map.to_hash).to eql(bare_hash.merge({
          to_maps: [[model_field, process]],
          public_fields: extra_fields,
          model_fields: [model_field]
        }))
      end
    end

    describe "#map_from_public" do
      let(:public_field) { :pub }
      let(:process) { Proc.new {|v| {one: v+1, two: v+2}} }
      it "creates the correct mapping" do
        proxy.map_from_public(public_field, &process)
        expect(proxy.map.to_hash).to eql(bare_hash.merge({
          from_maps: [[public_field, process]],
          public_fields: [public_field]
        }))
      end
    end

    describe "#hidden_field" do
      let(:hidden_field) { :hidden }
      it "adds a model_field" do
        proxy.hidden_field(hidden_field)
        expect(proxy.map.to_hash).to eql(bare_hash.merge({
          model_fields: [hidden_field]
        }))
      end
    end

    describe "#map_date" do
      let(:model_field) { :mod }
      let(:public_field) { :pub }
      let(:date_format) { "%Y-%m-%dT%H:%M:%SZ" }
      let(:time) { Time.new(2016, 10, 31, 12, 25, 33) }
      let(:time_string) { time.strftime(date_format)}
      it "creates the correct model_fields" do
        proxy.map_date(model_field, public_field, date_format)
        expect(proxy.map.model_fields).to eql([model_field])
      end
      it "creates the correct public_fields" do
        proxy.map_date(model_field, public_field, date_format)
        expect(proxy.map.public_fields).to eql([public_field])
      end
      it "creates the correct to_maps" do
        proxy.map_date(model_field, public_field, date_format)
        expect(proxy.map.to_maps[0]).to contain_exactly(model_field, an_instance_of(Proc))
      end
      it "creates the correct from_maps" do
        proxy.map_date(model_field, public_field, date_format)
        expect(proxy.map.from_maps[0]).to contain_exactly(public_field, an_instance_of(Proc))
      end
      it "defines a to_map that converts the model's date to the public's string" do
        proxy.map_date(model_field, public_field, date_format)
        expect(proxy.map.to_maps[0][1].call(time)).to eql({public_field => time_string})
      end
      it "defines a from_map that converts the public's string to the model's Time" do
        proxy.map_date(model_field, public_field, date_format)
        expect(proxy.map.from_maps[0][1].call(time_string)).to eql({model_field => time})
      end
      it "raises ArgumentError if date_format is nil" do
        expect {
          proxy.map_date(model_field, public_field, nil)
        }.to raise_error ArgumentError
      end
    end

    describe "#map_bool" do
      let(:model_field) { :mod }
      let(:public_field) { :pub }
      it "creates the correct model_fields" do
        proxy.map_bool(model_field, public_field)
        expect(proxy.map.model_fields).to eql([model_field])
      end
      it "creates the correct public_fields" do
        proxy.map_bool(model_field, public_field)
        expect(proxy.map.public_fields).to eql([public_field])
      end
      it "creates the correct to_maps" do
        proxy.map_bool(model_field, public_field)
        expect(proxy.map.to_maps[0]).to contain_exactly(model_field, an_instance_of(Proc))
      end
      it "creates the correct from_maps" do
        proxy.map_bool(model_field, public_field)
        expect(proxy.map.from_maps[0]).to contain_exactly(public_field, an_instance_of(Proc))
      end
      [true, false, nil].each do |bool|
        it "defines a to_map that converts models' #{bool} to public's #{bool}" do
          proxy.map_bool(model_field, public_field)
          expect(proxy.map.to_maps[0][1].call(bool)).to eql({public_field => bool})
        end
      end
      ["true", "True", "t", "T", "yes", "Yes", "Y", "y", "1"].each do |truthy_string|
        it "defines a from_map that converts public #{truthy_string} to model true" do
          proxy.map_bool(model_field, public_field)
          expect(proxy.map.from_maps[0][1].call(truthy_string)).to eql({model_field => true})
        end
      end
      ["false", "False", "f", "F", "no", "No", "N", "n", "0"].each do |falsey_string|
        it "defines a from_map that converts public #{falsey_string} to model false" do
          proxy.map_bool(model_field, public_field)
          expect(proxy.map.from_maps[0][1].call(falsey_string)).to eql({model_field => false})
        end
      end
      [nil, "nil", "null"].each do |null|
        it "defines a from_map that converts public #{null} to model nil" do
          proxy.map_bool(model_field, public_field)
          expect(proxy.map.from_maps[0][1].call(null)).to eql({model_field => nil})
        end
      end
    end

    



  end

end