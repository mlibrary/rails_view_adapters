require "faker"

Fabricator(:team) do
  name { Faker::Company.name }
end
