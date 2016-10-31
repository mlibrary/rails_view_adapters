# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "spec_helper"

# describe AbstractAdapter do
#
#   describe "map_bool" do
#     class MapBoolTestAdapter < AbstractAdapter
#       map_bool :params_bool, :public_bool
#     end
#     it "maps nil to nil" do
#       expect(MapBoolTestAdapter.from_public({public_bool: nil}).to_params_hash)
#         .to eql({params_bool: nil})
#     end
#   end
#
# end

module RailsViewAdapters
  describe AdapterBase do
    describe "::map_simple" do
      class TestAdapter < AdapterBase
        map_simple :model_type, :public_type
      end
      it "marks the simple fields" do
        expect(TestAdapter.from_public({public_type: 7}).to_params_hash)
          .to eql({model_type: 7})
      end
    end

  end
end