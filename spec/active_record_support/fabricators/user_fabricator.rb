require "faker"

Fabricator(:user) do
  name      { Faker::Name.name }
  join_date { Faker::Time.between( 2.years.ago, Time.now)}
  secret    { Faker::Internet.password }
end
