Fabricator(:post) do
  body { Faker::Lorem.paragraph }
  user { Fabricate(:user) }
end
