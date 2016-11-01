# frozen_string_literal: true
# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Matchers
  class FuzzyNestedMatcher
    def initialize(expected)
      @expected = expected
      @errors = nil
    end

    def matches?(actual)
      @errors ||= match(actual, @expected)
      @errors.nil?
    end

    def match_primitives(actual, expected)
      "expected #{expected}, got #{actual}" unless actual == expected
    end

    def match_times(actual, expected)
      diff = actual - expected
      "expected #{expected}, got #{actual}" unless diff.between?(-1, 1)
    end

    def match_hashes(actual, expected)
      unless actual.keys.sort == expected.keys.sort
        extra = (actual.keys - expected.keys).map {|key| "+#{key}" }
        missing = (expected.keys - actual.keys).map {|key| "-#{key}" }
        return { "Hash keys mismatch:" => extra + missing }
      end

      errors = {}
      actual.keys.each do |key|
        error = match(actual[key], expected[key])
        errors[key] = error if error
      end

      errors.empty? ? nil : errors
    end

    def match_arrays(actual, expected)
      unless actual.size == expected.size
        return "Actual size #{actual.size}, expected #{expected.size}"
      end
      errors = []
      actual.each_index do |i|
        error = match(actual[i], expected[i])
        errors[i] = error if error
      end
      errors.empty? ? nil : errors
    end

    def match_active_records(actual, expected)
      match_hashes(actual.attributes.except(:id), expected.attributes.except(:id))
    end

    def match(actual, expected)
      actual_responds_to = responders(actual)
      expected_responds_to = responders(expected)
      unless actual_responds_to == expected_responds_to
        return "Type mismatch: expected [#{expected_responds_to}], got [#{actual_responds_to}]"
      end
      if actual_responds_to.include? :push
        return match_arrays(actual, expected)
      elsif actual_responds_to.include? :has_key?
        return match_hashes(actual, expected)
      elsif actual.is_a? ActiveRecord::Base
        return match_active_records(actual, expected)
      elsif actual.respond_to? :strftime
        return match_times(actual, expected)
      else
        return match_primitives(actual, expected)
      end
    end

    def responders(obj)
      responds_to = []
      [:each, :push, :has_key?].each do |method|
        responds_to << method if obj.respond_to? method
      end
      responds_to
    end

    def failure_message
      @errors
    end

  end
end

def fuzzy_nested_match(actual)
  Matchers::FuzzyNestedMatcher.new(actual)
end
