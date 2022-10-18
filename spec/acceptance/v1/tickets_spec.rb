# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Tickets' do

	let!(:organization) { FactoryBot.create(:organization, name: "Josh", domain: ['joshsoftware.com']) }
	let!(:department_obj) { FactoryBot.create(:department, name: Faker::Name.name, organization_id: organization.id)}
	let!(:department_hr) { FactoryBot.create(:department, name: "HR", organization_id: organization.id)}
	let!(:category) { FactoryBot.create(:category, name: "Hardware", priority: 0, department_id: department_obj.id)}
	let!(:role) { FactoryBot.create(:role, name: 'super_admin')}
	let!(:role1) { FactoryBot.create(:role, name: 'employee')}
	let(:user) { FactoryBot.create(:user, role_id: role.id, email: "faker@joshsoftware.com", department_id: department_obj.id, organization_id: organization.id) }
	let(:user1) { FactoryBot.create(:user, role_id: role.id) }

  post '/tickets' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
		end
		context '200' do
      example 'Ticket created successfully ' do
        do_request(create_params("Laptop Issue", "RAM issue", category.id, department_obj.id, "request", user1.id))
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        expect(response_data["message"]).to eq(I18n.t('tickets.success.create'))
      end
    end

    context '422' do
      example 'Unable to create ticket' do
        do_request({"ticket": {
					"title": "Laptop",
					"description": "Urgent to resolve",
					"category_id": category.id,
					"department_id": department_obj.id,
					"resolver_id": user.id }
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('tickets.error.create'))
      end
    end
  end

	put 'tickets/:id' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
			@ticket = Ticket.create!(title: 'Laptop Issue', 
															 description: 'RAM Issue', 
															 category_id: category.id, 
															 department_id: department_obj.id, 
															 ticket_type: 'request', 
															 resolver_id: user1.id,
															 requester_id: user1.id)
		end
		context '200' do
			let(:id) {@ticket.id}
      example 'Ticket Updated successfully ' do
				@ticket.start
				@ticket.resolve
				@ticket.save
        do_request({
					"ticket_result": {
						"is_customer_satisfied": false,
						"rating": 2,
						"state_action": "reopen",
						"started_reason": "Not satisfied with your service"
					}
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        expect(response_data["message"]).to eq(I18n.t('tickets.success.reopen'))
      end
    end

		context '422' do
			let(:id) {@ticket.id}
			example 'Could not reopen ticket due to invalid transition' do
				@ticket.start
        do_request({
					"ticket_result": {
						"is_customer_satisfied": false,
						"rating": 2,
						"state_action": "reopen",
						"started_reason": "Not satisfied with your service"
					}
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('tickets.error.update'))
				expect(response_data["errors"]).to eq(response_data["errors"])
      end
		end
	end

	get 'tickets' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
			@ticket = Ticket.create!(title: 'Laptop Issue', 
															 description: 'RAM Issue', 
															 category_id: category.id, 
															 department_id: department_obj.id, 
															 ticket_type: 'request', 
															 resolver_id: user1.id,
															 requester_id: user1.id)
		end

		context '200' do
			example 'show ticket without filters' do
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data).to eq(response_data)
			end

			example 'show ticket with one filter' do
				do_request({department: department_obj.name})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data).to eq(response_data)
			end

			example 'show ticket with multiple filters' do
				do_request({department: department_obj.name, category: category.name})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data).to eq(response_data)
			end
		end

		context '422' do
			example 'invalid filters' do
				do_request({department: "NonExistingDepartment"})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(422)
				expect(response_data["message"]).to eq(response_data["message"])
			end

			example 'Combination of valid and invalid filter' do
				do_request({department: department_obj.name, category: "NonExistingCategory"})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(422)
				expect(response_data["message"]).to eq(response_data["message"])
			end
		end

		context '404' do 
			parameter :department, with_example: true
			let(:department) { "HR" }
			example 'no ticket with given filters' do
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(404)
				expect(response_data["message"]).to eq(response_data["message"])
			end
		end
	end

	private

	def create_params(title, description, category_id, department_id, ticket_type, resolver_id)
		{
			"ticket":
			{
					"title": title,
					"description": description,
					"category_id": category_id,
					"department_id": department_id,
					"ticket_type": ticket_type,
					"resolver_id": resolver_id
			}
		}
	end
end
