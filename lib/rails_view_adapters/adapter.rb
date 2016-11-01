# frozen_string_literal: true
require "rails_view_adapters/definition_proxy"
require "rails_view_adapters/map"
require "rails_view_adapters/adapter_base"

module RailsViewAdapters

  # Top level namespace for defining the adapters.
  module Adapter

    FIELDS = [
      :model_fields, :public_fields,
      :to_maps, :from_maps, :simple_maps
    ].freeze

    def self.define(name, &block)
      proxy = DefinitionProxy.new(Map.new)
      proxy.instance_eval(&block)
      Object.const_set(name.to_s.classify, adapter_from_map(proxy.map))
    end

    def self.adapter_from_map(map)
      Class.new(AdapterBase) do
        FIELDS.each do |method|
          define_singleton_method method do
            map.send(method)
          end
        end
      end
    end

  end

end
