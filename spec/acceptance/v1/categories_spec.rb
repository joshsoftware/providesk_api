
require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Categories' do
  let!(:organization) { FactoryBot.create(:organization, name: "Josh") }
	let!(:department) { FactoryBot.create(:department, name: Faker::Name.name, organization_id: organization.id)}
	let!(:category) { FactoryBot.create(:category, name: "Hardware", priority: "High", department_id: user.department_id)}
	let!(:role) { FactoryBot.create(:role, name: 'department_head')}
	let!(:user) { FactoryBot.create(:user, role_id: role.id) }

  post '/categories' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
		end
		context '200' do
      example 'Categories created successfully' do
        do_request({category: {
					name: "Software",
          priority: "Regular",
					department_id: user.department_id,
          sla_unit: 3,
          sla_duration_type: 'Days' 
          } 
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        expect(response_data["message"]).to eq(I18n.t('categories.success.create'))
      end
    end

    context   '422' do
      example 'Unable to create category due to invalid parameters' do
        do_request({"category": {} })
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["errors"]).to eq(I18n.t('missing_params'))
      end

      example 'Unable to create category due to already existing name' do
        do_request({"category": {
					"name": "Hardware",
          "priority": "Regular",
					"department_id": user.department_id,
          "sla_unit": 3,
          "sla_duration_type": 'Days'
          } 
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('categories.error.create'))
        expect(response_data["errors"]).to eq(I18n.t('categories.error.exists'))
      end

      example "Unable to create category when name is blank" do
        do_request({"category": {
          "priority": "Regular",
          "department_id": user.department_id,
          "sla_unit": 3,
          "sla_duration_type": 'Days'
          } 
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('categories.error.create'))
        expect(response_data["errors"]).to eq("Name can't be blank")
      end

      example "Unable to create category when department is blank" do
        do_request({"category": {
          "name": "Software",
          "priority": "Regular",
          "sla_unit": 3,
          "sla_duration_type": 'Days'
          } 
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('categories.error.create'))
        expect(response_data["errors"]).to eq("Department must exist")
      end
    end
  end
end
