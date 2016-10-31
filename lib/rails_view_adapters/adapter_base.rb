# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module RailsViewAdapters
  class AdapterBase
    # Create an instance from an ActiveRecord model.
    # @param [ActiveRecord::AdapterBase] model
    # @return the adapter
    def self.from_model(model)
      internals = {}
      model_fields.each do |field|
        internals[field] = model.send(field)
      end
      self.new(internals, {})
    end


    # Create an instance from a public representation.
    # @param [ActionController::Parameters] public
    # @return the adapter
    def self.from_public(public)
      internals = {}
      simple_maps.each do |model_field, public_field|
        internals[model_field] = public[public_field]
      end

      extras = {}
      (public.keys.map{|k|k.to_sym} - public_fields).each do |extra_key|
        extras[extra_key] = public[extra_key]
      end

      from_maps.each do |public_field, process|
        internals.merge!(process.call(public[public_field]))
      end

      self.new(internals, extras)
    end


    def initialize(internals, extras)
      @internals = internals
      @extras = extras
      @public_hash = nil
      @params_hash = nil
    end


    def to_params_hash
      @params_hash ||= to_model_hash.merge(@extras.symbolize_keys) {|key,lhs,rhs| lhs}
    end


    def to_json(options = {})
      return self.to_public_hash.to_json(options)
    end


    def to_model_hash
      @internals
    end


    def to_public_hash
      unless @public_hash
        @public_hash = {}
        simple_maps.each do |model_field, public_field|
          @public_hash[public_field] = @internals[model_field]
        end
        to_maps.each do |model_field, process|
          @public_hash.merge!(process.call(@internals[model_field])) do |k,l,r|
            merge_strategy.call(k,l,r)
          end
        end
      end
      @public_hash
    end


    private

    # Define an instance method for each of the class methods
    # we want to access, otherwise we have to prepend
    # "self.class." each time.
    [:simple_maps, :to_maps].each do |method_name|
      define_method(method_name) do
        self.class.send(method_name)
      end
    end

    def merge_strategy
      @merge_strategy ||= Proc.new do |key, lhs, rhs|
        if lhs.respond_to?(:merge) && rhs.respond_to?(:merge)
          lhs.merge(rhs)
        else
          rhs
        end
      end
    end

  end
end