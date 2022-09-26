
require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Categories' do
  let!(:organization) { FactoryBot.create(:organization, name: "Josh") }
	let!(:department) { FactoryBot.create(:department, name: Faker::Name.name, organization_id: organization.id)}
	let!(:category) { FactoryBot.create(:category, name: "Hardware", priority: "High", department_id: department.id)}
	let!(:role) { FactoryBot.create(:role, name: 'employee')}
	let!(:user) { FactoryBot.create(:user, role_id: role.id) }

  post '/categories' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
		end
		context '200' do
      example 'Categories created successfully' do
        do_request({"categories": {
					"name": "Software",
          "priority": 0,
					"department_id": department.id,
          } 
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        expect(response_data["message"]).to eq(I18n.t('categories.success.create'))
      end
    end

    context '422' do
      example 'Unable to create category' do
        do_request({"categories": {
					"name": "Hardware",
          "priority": 0,
					"department_id": department.id,
          } 
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('categories.error.create'))
      end
    end
  end
end