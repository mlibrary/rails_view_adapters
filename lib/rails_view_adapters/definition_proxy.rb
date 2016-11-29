# frozen_string_literal: true

require "active_support/time_with_zone"

module RailsViewAdapters

  # Defines the DSL methods that are used to modify the underlying
  # map.  This class is only used to evaluate the DSL calls, thereby
  # modifying the Map.
  class DefinitionProxy
    attr_accessor :map
    def initialize(adapter_map)
      @map = adapter_map
    end

    # Register a simple one-to-one mapping.
    # @param [Symbol] model_field
    # @param [Symbol] public_field
    def map_simple(model_field, public_field)
      map.add_simple_map(model_field, public_field)
    end

    # Register a mapping from a model field to the public representation.
    # @param [Symbol] model_field
    # @param [Array<Symbol>] extra_public_fields Used to tell the adapter about
    #   extra public fields created by this mapping.
    # @yield [model_value] Given the value of the model's model_field, return
    #   a hash of key:values pairs to merge into the public representation.
    def map_to_public(model_field, extra_public_fields = [], &block)
      map.add_to_map(model_field, &block)
      extra_public_fields.each do |public_field|
        map.add_public_field(public_field)
      end
    end

    # Register a mapping from a public field to the model representation.
    # @param [Symbol] public_field
    # @yield [public_value] Given the value of public representation's
    #   public_field, return a hash of key:value pairs to merge into
    #   the internal model representation.
    def map_from_public(public_field, &block)
      map.add_from_map(public_field, &block)
    end

    # Register a hidden field, i.e. a field not present in public representations.
    # @param [Symbol] model_field
    def hidden_field(model_field)
      map.add_model_field(model_field)
    end

    # Register a one-to-one mapping of a date field. When converting
    # from the public representation, if the non-string values are
    # returned as-is.  Strings that cannot be parsed with the given
    # date_format string are returned as nil.
    #
    # If no timezone is provided, utc is assumed.
    # @param [Symbol] model_field
    # @param [Symbol] public_field
    # @param [String] date_format The Date format to use.
    def map_date(model_field, public_field, date_format)
      raise ArgumentError if date_format.nil?
      map_from_public public_field do |value|
        { model_field => time_from_public(value, date_format) }
      end
      map_to_public model_field do |value|
        { public_field => value.utc.strftime(date_format) }
      end
    end

    # Register a one-to-one mapping of a boolean field
    # @param [Symbol] model_field
    # @param [Symbol] public_field
    def map_bool(model_field, public_field)
      map_from_public public_field do |value|
        { model_field => to_bool(value) }
      end

      map_to_public model_field do |value|
        { public_field => value }
      end
    end

    # Register a mapping of a belongs_to association.
    # @param [Symbol] model_field  The field on the model that holds the association,
    #   usually the association's name.
    # @param [Symbol] public_field The public field.
    # @param [Hash] options
    # @option options [Class] :model_class The class of the associated model,
    #   if it cannot be inferred from the model_field.
    # @option options [Symbol] :sub_method The method of the association model
    #   that holds the desired data.  Default is :id.
    # @option options [Symbol] :only Only create the to_map or the from_map, as
    #   directed by setting this to :to or :from, respectively.
    def map_belongs_to(model_field, public_field, options = {})
      model_class = options[:model_class] || model_field.to_s.classify.constantize
      sub_method = options[:sub_method] || :id

      unless options[:only] == :to
        map_from_public public_field do |value|
          record = model_class.send(:"find_by_#{sub_method}", value)
          { model_field => record ? record : model_class.new(sub_method => value) }
        end
      end

      unless options[:only] == :from
        map_to_public model_field do |record|
          { public_field => record.send(sub_method) }
        end
      end
    end

    # Register a mapping of a has_many association.
    # @param [Symbol] model_field  The field on the model that holds the association,
    #   usually the association's name.
    # @param [Symbol] public_field The public field.
    # @param [Hash] options
    # @option options [Class] :model_class The class of the model, if it cannot
    #   be inferred from the model_field.
    # @option options [Symbol] :sub_method The method of the association model
    #   that holds the desired data.  If this isn't provided, it's assumed
    #   to be the same as public_field.
    def map_has_many(model_field, public_field, options = {})
      model_class = options[:model_class] || model_field.to_s.classify.constantize
      sub_method = options[:sub_method] || public_field

      unless options[:only] == :to
        map_from_public public_field do |value|
          result = { model_field => model_class.where(sub_method => value) }
          public_field_size = value.respond_to?(:size) ? value.size : 0
          result[model_field] = result[model_field]
            .to_a
            .fill(nil, result[model_field].size, public_field_size - result[model_field].size)
          result
        end
      end

      unless options[:only] == :from
        map_to_public model_field do |records|
          { public_field => records.map(&sub_method.to_sym) }
        end
      end
    end

    private

    def time_from_public(time, date_format)
      if time.is_a? String
        parts_to_time(DateTime._strptime(time, date_format))
      else
        time
      end
    end

    def parts_to_time(parts)
      return nil if parts.empty?
      begin
        time = Time.new(
          parts.fetch(:year),
          parts.fetch(:mon),
          parts.fetch(:mday),
          parts.fetch(:hour),
          parts.fetch(:min),
          parts.fetch(:sec) + parts.fetch(:sec_fraction, 0),
          parts.fetch(:offset, 0)
        )
      rescue KeyError
        return nil
      end

      ActiveSupport::TimeWithZone.new(time.utc, Time.zone)
    end

    def to_bool(value)
      return nil if value.nil? || value =~ /^(null|nil)$/i
      return true if value == true || value =~ /^(true|t|yes|y|1)$/i
      return false if value == false || value =~ /^(false|f|no|n|0)$/i
      raise ArgumentError, "invalid value for boolean: \"#{value}\""
    end

  end
end
