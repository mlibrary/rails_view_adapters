module RailsViewAdapters

  # Contains the information needed by the adapters
  # to convert from one form to another.
  class Map
    attr_accessor :model_fields, :public_fields
    attr_accessor :simple_maps, :to_maps, :from_maps
    def initialize
      @simple_maps = []
      @model_fields = []
      @public_fields = []
      @to_maps = []
      @from_maps = []
    end

    def add_model_field(model_field)
      model_fields << model_field
      self
    end

    def add_public_field(public_field)
      public_fields << public_field
      self
    end

    def add_simple_map(model_field, public_field)
      simple_maps << [model_field, public_field]
      add_model_field(model_field)
      add_public_field(public_field)
      self
    end

    def add_to_map(model_field, &block)
      to_maps << [model_field, block]
      add_model_field(model_field)
      self
    end

    def add_from_map(public_field, &block)
      from_maps << [public_field, block]
      add_public_field(public_field)
      self
    end
  end
end