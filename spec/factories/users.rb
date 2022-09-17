FactoryBot.define do
  factory :user do
    name { "XYZ" }
    email { 'xyz@gmail.com' }
    role
    organization
  end
end
