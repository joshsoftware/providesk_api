FactoryBot.define do
  factory :ticket do
    title { Faker::Name.name}
  end
end
