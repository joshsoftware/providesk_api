FactoryBot.define do
  factory :user do
    name { "XYZ" }
    email { Faker::Internet.email }
    role_id { create(:role, name: 'admin').id }
    organization_id { create(:organization, name: Faker::Name.name, domain: [email.split('@')[1]]).id }
    department_id { create(:department, name: Faker::Name.name, organization_id: organization_id).id }
  end
end
