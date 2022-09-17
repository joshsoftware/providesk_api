FactoryBot.define do
  factory :department do
    name {Faker::Name.unique.name}
  end
end
