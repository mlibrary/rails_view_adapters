# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "spec_helper"

module RailsViewAdapters
  describe Adaptation do

    describe "map_simple" do
      class TestAdapter
        extend Adaptation
        map_simple :model_a, :public_a
        map_simple :model_b, :public_b
      end

      it "sets public_fields" do
        expect(TestAdapter.public_fields).to eql([:public_a, :public_b])
      end
      it "sets model_fields" do
        expect(TestAdapter.model_fields).to eql([:model_a, :model_b])
      end
      it "sets simple_maps" do
        expect(TestAdapter.simple_maps).to eql([[:model_a, :public_a],[:model_b, :public_b]])
      end
      it "sets to_maps" do
        expect(TestAdapter.to_maps).to eql([])
      end
      it "sets from_maps" do
        expect(TestAdapter.from_maps).to eql([])
      end
    end

    describe "map_date" do

    end
    describe "map_bool"
    describe "map_belongs_to"
    describe "map_has_many"
    describe "map_to_public" do
      wtf = Proc.new do |model_value|
        { public_c1: model_value, public_c2: model_value * 2}
      end
      class TestAdapter
        extend Adaptation
        map_to_public :model_c, [:public_c1, :public_c2], &(self.wtf)
      end
      it "sets public_fields" do
        expect(TestAdapter.public_fields).to eql([:public_c1, :public_c2])
      end
      it "sets model_fields" do
        expect(TestAdapter.model_fields).to eql([:model_c])
      end
      it "sets simple_maps" do
        expect(TestAdapter.simple_maps).to eql([])
      end
      it "sets to_maps" do
        expect(TestAdapter.to_maps).to eql([:model_c, block])
      end
      it "sets from_maps" do
        expect(TestAdapter.from_maps).to eql([])
      end
    end
    describe "map_from_public"

  end
end