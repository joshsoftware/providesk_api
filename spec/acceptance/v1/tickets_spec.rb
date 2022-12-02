# frozen_string_literal: true
require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Tickets' do

	let!(:organization) { FactoryBot.create(:organization, name: "Josh", domain: ['joshsoftware.com']) }
	let!(:department_obj) { FactoryBot.create(:department, name: Faker::Name.name, organization_id: organization.id)}
	let!(:department_hr) { FactoryBot.create(:department, name: "HR", organization_id: organization.id)}
	let!(:category) { FactoryBot.create(:category, name: "Hardware", priority: 0, department_id: department_obj.id)}
	let!(:role) { FactoryBot.create(:role, name: Role::ROLE[:department_head])}
	let!(:role1) { FactoryBot.create(:role, name: Role::ROLE[:employee])}
	let(:user) { FactoryBot.create(:user, role_id: role.id, email: "faker@joshsoftware.com", department_id: department_obj.id, organization_id: organization.id) }
	let(:user1) { FactoryBot.create(:user, role_id: role.id) }
	let(:employee) { FactoryBot.create(:user, role_id: role1.id, email: "employee@joshsoftware.com", department_id: department_obj.id, organization_id: organization.id)}

  post '/tickets' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
		end
		context '200' do
      example 'Ticket created successfully - without image' do
        do_request(create_params("Laptop Issue", "RAM issue", category.id, department_obj.id, "Request", user.id, nil))
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        expect(response_data["message"]).to eq(I18n.t('tickets.success.create'))
      end
			example 'Ticket created successfully - with image' do
        do_request(create_params("Laptop Issue", "RAM issue", category.id, department_obj.id, "Request", user.id, "image"))
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

			example 'Unable to create ticket - Department must exist' do
        do_request({ "ticket": ticket_params.except(:department_id) })
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('tickets.error.create'))
				expect(response_data["errors"]).to eq(I18n.t('tickets.error.department'))
      end

			example 'Unable to create ticket - Resolver must exist' do
        do_request({ "ticket": ticket_params.except(:resolver_id) })
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('tickets.error.create'))
				expect(response_data["errors"]).to eq(I18n.t('tickets.error.resolver'))
      end

			example 'Unable to create ticket - Category must exist' do
        do_request({ "ticket": ticket_params.except(:category_id) })
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('tickets.error.create'))
				expect(response_data["errors"]).to eq(I18n.t('tickets.error.category'))
      end

			example 'Unable to create ticket - invalid params' do
				do_request({})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(422)
				expect(response_data["errors"]).to eq(I18n.t('missing_params'))
			end
    end
  end

	put 'tickets/:id/reopen' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
			@ticket = Ticket.create!(title: 'Laptop Issue', 
															 description: 'RAM Issue', 
															 category_id: category.id, 
															 department_id: department_obj.id, 
															 ticket_type: 'Request', 
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

	put 'tickets/:id/reopen' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
			@ticket = Ticket.create!(title: 'Laptop Issue', 
															 description: 'RAM Issue', 
															 category_id: category.id, 
															 department_id: department_obj.id, 
															 ticket_type: 'Request', 
															 resolver_id: user1.id,
															 requester_id: user1.id)
		end
		context '200' do
			let(:id) {@ticket.id}
      example 'Ticket reopened successfully ' do
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

	put 'tickets/:id' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
			@ticket = Ticket.create!(title: 'Laptop Issue', 
															 description: 'RAM Issue', 
															 category_id: category.id, 
															 department_id: department_obj.id, 
															 ticket_type: 'Request', 
															 resolver_id: user.id,
															 requester_id: user1.id,
															 organization_id: user.organization_id)
			@department = Department.create!(name: "Test Department", organization_id: user.organization_id)
			@category = Category.create!(name: "Category for Test Department", department_id: @department.id)
			@resolver = User.create!(name: "testuser", role_id: role.id, email: "shefali@joshsoftware.com", 
															 department_id: @department.id, organization_id: user.organization_id)
		end
		context '200' do
			let(:id) {@ticket.id}
			example 'Ticket updated succesfully - changing department_id' do
				do_request({ticket: { department_id: @department.id }})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.update'))
			end

			example 'Ticket updated succesfully - changing department and category_id' do
				do_request({ticket: { department_id: @department.id, category_id: @category.id}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.update'))
			end

			example 'Ticket updated succesfully - changing department and resolver_id' do
				do_request({ticket: { department_id: @department.id, resolver_id: @resolver.id}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.update'))
			end

			example 'Ticket updated succesfully - changing status' do
				do_request({ticket: { status: "inprogress"}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.update'))
			end

			example 'Ticket updated successfully - added image' do 
				do_request({ticket: { asset_url: "image" }})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.update'))
			end
		end

		context '422' do
			let(:id) {@ticket.id}
			example 'Could not update ticket - Invalid department_id' do
				do_request({ticket: { department_id: 0}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(422)
				expect(response_data["message"]).to eq(I18n.t('tickets.error.update'))
				expect(response_data["errors"]).to eq(I18n.t('tickets.error.department'))
			end

			example 'Could not update ticket - Invalid transition for status' do
				do_request({ticket: { status: "closed"}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(422)
				expect(response_data["message"]).to eq(I18n.t('tickets.error.update'))
				expect(response_data["errors"]).to eq(response_data["errors"])
			end

			example 'Could not update ticket - Invalid category_id' do
				do_request({ticket: { category_id: 0}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(422)
				expect(response_data["message"]).to eq(I18n.t('tickets.error.update'))
				expect(response_data["errors"]).to eq(I18n.t('tickets.error.category'))
			end

			example 'Could not update ticket - Invalid resolver_id' do
				do_request({ticket: { resolver_id: 0}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(422)
				expect(response_data["message"]).to eq(I18n.t('tickets.error.update'))
				expect(response_data["errors"]).to eq(I18n.t('tickets.error.resolver'))
			end
		end

		context '401' do 
			before do
				@ticket = Ticket.create!(
					title: 'Laptop Issue', 
					description: 'RAM Issue', 
					category_id: category.id, 
					department_id: department_obj.id, 
					ticket_type: 'Request', 
					resolver_id: user1.id,
					requester_id: user.id)
			end
			let(:id) {@ticket.id}
			example 'Could not update ticket created by himself' do
				do_request({ ticket: {department_id: department_hr.id }})
				expect(response_status).to eq(401)
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
															 ticket_type: 'Request', 
															 resolver_id: user.id,
															 requester_id: user1.id)
		end

		context '200' do
			example 'show ticket without filters' do
				do_request()
				expect(response_status).to eq(200)
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

			parameter :type, with_example: true
			let(:type) { 'Complaint' }
			example 'no tickets with given filter' do
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["data"]).to eq([])
				expect(response_data["message"]).to eq(I18n.t('tickets.show.not_availaible'))
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
	end

	get 'tickets/:id' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: employee.id, email: employee.email, name: employee.name})
			@ticket = Ticket.create!(title: 'Laptop Issue', 
															 description: 'RAM Issue', 
															 category_id: category.id, 
															 department_id: department_obj.id, 
															 ticket_type: 'Request', 
															 resolver_id: user.id,
															 requester_id: employee.id)
		end
		context '200' do
			let(:id) {@ticket.id}
			example 'Show ticket' do
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["data"]).to eq(response_data["data"])
				expect(response_data["activities"]).to eq(response_data["activities"])
			end	
		end

		context '404' do
			let(:id) {Faker::Base.numerify(text = '#@%!')}
			example 'Could not find ticket' do
				@ticket.update(requester_id: employee.id)
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(404)
				expect(response_data["errors"]).to eq(I18n.t('record_not_found'))
			end	
		end
	end

	private

	def create_params(title, description, category_id, department_id, ticket_type, resolver_id, asset_url)
		{
			"ticket":
			{
					"title": title,
					"description": description,
					"category_id": category_id,
					"department_id": department_id,
					"ticket_type": ticket_type,
					"resolver_id": resolver_id,
					"asset_url": asset_url
			}
		}
	end

	def ticket_params
		{
			"title": "Laptop issue",
			"description": "Urgent to resolve",
			"category_id": category.id,
			"department_id": department_obj.id,
			"ticket_type": "Request",
			"resolver_id": user.id
		}
	end
end
