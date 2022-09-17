FactoryBot.define do
  factory :user do
    name { "XYZ" }
    email { 'xyz@gmail.com' }
    role_id { create(:role, name: 'admin').id }
    organization_id { create(:organization, name: 'GMAIL', domain: ['gmail.com']) }
  end
end
