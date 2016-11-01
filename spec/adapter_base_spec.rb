require "spec_helper"
require "active_record_helper"

module RailsViewAdapters
  describe AdapterBase do

    class TestAdapter < AdapterBase
      def self.simple_maps
        [[:body, :post_text]]
      end
      def self.to_maps
        [[:user_id, Proc.new{|v| {user_name: v + 10}}]]
      end
      def self.from_maps
        [[:user_name, Proc.new{|v| {user_id: v + 100}}]]
      end
      def self.model_fields
        [:body, :user_id]
      end
      def self.public_fields
        [:post_text, :user_name]
      end
    end
    class ARTestAdapter < TestAdapter
      def self.to_maps
        [[:user_id, Proc.new{|v| {user_name: User.find(v).name}}]]
      end
      def self.from_maps
        [[:user_name, Proc.new{|v| {user_id: User.find_by_name(v).id}}]]
      end
    end

    describe "#to_model_hash" do
      let(:internals) { {a: 1, b: 2} }
      it "returns the internals" do
        expect(described_class.new(internals, {}).to_model_hash).to eql(internals)
      end
    end

    describe "#to_params_hash" do
      let(:internals) { {a: 1, b: 2} }
      let(:disjoint_extras) { {c: 3} }
      let(:overlapping_extras) {{b: 27, c: 3}}
      it "merges internals and extras" do
        expect(described_class.new(internals, disjoint_extras).to_params_hash)
          .to eql({a:1, b:2, c:3})
      end
      it "prefers internals over extras" do
        expect(described_class.new(internals, overlapping_extras).to_params_hash)
          .to eql({a:1, b:2, c:3})
      end
      it "symbolizes keys" do
        expect(described_class.new(internals, {"c" => 3}).to_params_hash)
          .to eql({a:1, b:2, c:3})
      end
    end

    describe "#to_public_hash" do
      let(:internals) { {body: 2, user_id: 4} }
      let(:extras) { {extra_field: "asdf"} }
      let(:adapter) { TestAdapter.new(internals, extras) }
      it "returns the public hash w/o extras" do
        expect(adapter.to_public_hash).to eql({
          post_text: 2,
          user_name: 14
        })
      end
    end

    describe "#to_json" do
      let(:adapter) { described_class.new({}, {})}
      let(:public_hash) { double(:public_hash) }
      let(:options) { {a: 11313, b: 1231} }
      it "delegates to #to_json on the public hash" do
        allow(adapter).to receive(:to_public_hash).and_return(public_hash)
        expect(public_hash).to receive(:to_json).with(options)
        adapter.to_json(options)
      end
    end

    describe "::from_model" do
      let(:model) { Fabricate(:post) }
      it "instantiates the adapter" do
        expect(TestAdapter.from_model(model)).to be_an_instance_of(TestAdapter)
      end
      it "loads the model as its internals" do
        expect(TestAdapter.from_model(model).to_model_hash).to eql({
          body: model.body,
          user_id: model.user_id
        })
      end
    end

    describe "::from_public" do
      let(:user) { Fabricate(:user) }
      let(:input_hash) do
        {
          post_text: Faker::Lorem.paragraph,
          user_name: user.name,
          extra_field: 12345
        }
      end
      it "instantiates the adapter" do
        expect(ARTestAdapter.from_public(input_hash)).to be_an_instance_of(ARTestAdapter)
      end
      it "loads the internals" do
        expect(ARTestAdapter.from_public(input_hash).to_model_hash).to eql({
          body: input_hash[:post_text],
          user_id: user.id
        })
      end
      it "loads the extras" do
        expect(ARTestAdapter.from_public(input_hash).to_params_hash).to eql({
          body: input_hash[:post_text],
          user_id: user.id,
          extra_field: 12345
        })
      end
      it "doesn't mutate the public representation" do
        expect(ARTestAdapter.from_public(input_hash).to_public_hash).to eql({
          post_text: input_hash[:post_text],
          user_name: input_hash[:user_name]
        })
      end
    end




  end
end