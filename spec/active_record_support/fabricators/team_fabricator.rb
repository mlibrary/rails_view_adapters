# frozen_string_literal: true
require "faker"

Fabricator(:team) do
  name { Faker::Company.name }
end
