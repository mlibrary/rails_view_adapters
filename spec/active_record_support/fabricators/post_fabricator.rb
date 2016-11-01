# frozen_string_literal: true
require "faker"

Fabricator(:post) do
  body { Faker::Lorem.paragraph }
  user { Fabricate(:user) }
end
