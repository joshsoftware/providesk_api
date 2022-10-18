# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Tickets' do

	let!(:organization) { FactoryBot.create(:organization, name: "Josh") }
	let!(:department_obj) { FactoryBot.create(:department, name: Faker::Name.name, organization_id: organization.id)}
	let!(:department_hr) { FactoryBot.create(:department, name: "HR", organization_id: organization.id)}
	let!(:category) { FactoryBot.create(:category, name: "Hardware", priority: 0, department_id: department_obj.id)}
	let!(:role) { FactoryBot.create(:role, name: 'super_admin')}
	let!(:role1) { FactoryBot.create(:role, name: 'employee')}
	let(:user) { FactoryBot.create(:user, role_id: role.id, department_id: department_obj.id) }
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
      example 'Unable to create ticket - Title must exist' do
        do_request({ "ticket": ticket_params.except(:title) })
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('tickets.error.create'))
				expect(response_data["errors"]).to eq("Title can't be blank")
      end

			example 'Unable to create ticket - Description not provided' do
        do_request({ "ticket": ticket_params.except(:description) })
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('tickets.error.create'))
				expect(response_data["errors"]).to eq("Description can't be blank")
      end

			example 'Unable to create ticket - Ticket type blank' do
        do_request({ "ticket": ticket_params.except(:ticket_type) })
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('tickets.error.create'))
				expect(response_data["errors"]).to eq("Ticket type can't be blank")
      end

			example 'Unable to create ticket - Department does not exist' do
        do_request({ "ticket": ticket_params.except(:department_id) })
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('tickets.error.create'))
				expect(response_data["errors"]).to eq("Resolver must exist")
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
				expect(response_status).to eq(200)
			end
			parameter :department, with_example: true
			let(:department) { department_obj.name }
			example 'show ticket with filters' do
				do_request()
				expect(response_status).to eq(200)
			end
		end

		context '422' do 
			parameter :department, with_example: true
			let(:department) { "NonExistingDepartment" }
			example 'invalid filters' do
				do_request()
				expect(response_status).to eq(422)
			end
		end
		context '404' do 
			parameter :department, with_example: true
			let(:department) { "HR" }
			example 'no ticket with given filters' do
				do_request()
				expect(response_status).to eq(404)
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
				expect(response_status).to eq(200)
			end
			parameter :department, with_example: true
			let(:department) { department_obj.name }
			example 'show ticket with filters' do
				do_request()
				expect(response_status).to eq(200)
			end
		end

		context '422' do 
			parameter :department, with_example: true
			let(:department) { "NonExistingDepartment" }
			example 'invalid filters' do
				do_request()
				expect(response_status).to eq(422)
			end
		end
		context '404' do 
			parameter :department, with_example: true
			let(:department) { "HR" }
			example 'no ticket with given filters' do
				do_request()
				expect(response_status).to eq(404)
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

	def ticket_params
		{
			"title": "Laptop issue",
			"description": "Urgent to resolve",
			"category_id": category.id,
			"department_id": department.id,
			"ticket_type": "request",
			"resolver_id": user.id
		}
	end
end
