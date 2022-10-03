
require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Users' do
	Organization.destroy_all
	let!(:organization) { Organization.create!(name: "Josh", domain: ["joshsoftware.com"]) }
	let!(:department) { FactoryBot.create(:department, name: Faker::Name.name, organization_id: organization.id)}
	let!(:category) { FactoryBot.create(:category, name: "Hardware", priority: "High", department_id: department.id)}
	let!(:role) { FactoryBot.create(:role, name: 'employee')}
	let!(:user) { FactoryBot.create(:user, role_id: role.id) }
	before do
		header 'Accept', 'application/vnd.providesk; version=1'
		header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
	end

	put '/users/:id' do
		context '200' do
			let!(:user) { User.create(name: "prathamgoel", email: "pratham.goel@joshsoftware.com") }
			let(:id) { User.where(name: "prathamgoel")[0].id }
			example 'a successful updation of a user' do
				header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
				do_request({
					"user_data": {
						"email": "pratham.goelupdated@joshsoftware.com",
						"name": "prathamgoel"
					}
				})
				response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('users.success.update'))
			end
		end
		context '422' do
			let!(:user) { User.create(name: "prathamgoel", email: "pratham.goel@joshsoftware.com") }
			let(:id) { 0 }
			example 'a successful updation of a user' do
				header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
				do_request({
					"user_data": {
						"email": "pratham.goelupdated@joshsoftware.com",
						"name": "prathamgoel"
					}
				})
				response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
				expect(response_data["message"]).to eq(I18n.t('users.error.update'))
			end
		end
	end

  post '/users' do
		context '200' do
			example 'a successful creation of a user' do
				do_request({
					"user_data": {
						"name": "Sandeep Goel",
						"email": "sandeep@joshsoftware.com",
						"role_id": Role.first.id,
						"organization_id": Organization.first.id
					}
				})
				response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('users.success.create'))
			end
		end
		context '200' do
			example 'a unsuccessful creation of a user' do
				do_request({
					"user_data": {
						"name": "Sandeep Goel",
						"email": "sandeep@joshsoftware.com",
						"role_id": 0,
						"organization_id": Organization.first.id
					}
				})
				response_data = JSON.parse(response_body)
        expect(status).to eq(422)
				expect(response_data["message"]).to eq(I18n.t('users.error.create'))
			end
		end
	end

	get '/users/:id' do
		context '200' do
			let(:id) {User.first.id}
			example 'Show a existing user' do
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["status"]).to eq(true)
			end
		end
		context '422' do
			let(:id) {0}
			example 'Show a non existing user' do
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(422)
			end
		end
	end

	delete 'users/:id' do
		context '200' do
			let(:id) {User.first.id}
			example 'Deleting a existing user' do
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["status"]).to eq(true)
			end
		end
		context '422' do
			let(:id) {0}
			example 'Deleting a non xisting user' do
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(422)
				expect(response_data["status"]).to eq(false)
			end
		end
	end
end