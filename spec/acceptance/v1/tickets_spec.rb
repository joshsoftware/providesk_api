# frozen_string_literal: true
require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Tickets' do

	let!(:organization) { FactoryBot.create(:organization, name: "Josh", domain: ['joshsoftware.com']) }
	let!(:department_obj) { FactoryBot.create(:department, name: Faker::Name.name, organization_id: organization.id)}
	let!(:department_hr) { FactoryBot.create(:department, name: "HR", organization_id: organization.id)}
	let!(:category) { FactoryBot.create(:category, name: "Hardware", priority: 0, department_id: department_obj.id, sla_unit: 3,
																								 sla_duration_type: 'Days', duration_in_hours: 72)}
	let!(:role) { FactoryBot.create(:role, name: Role::ROLE[:department_head])}
	let!(:role1) { FactoryBot.create(:role, name: Role::ROLE[:employee])}
	let!(:role2) { FactoryBot.create(:role, name: Role::ROLE[:resolver])}
	let(:user) { FactoryBot.create(:user, role_id: role.id, email: "faker@joshsoftware.com", department_id: department_obj.id, organization_id: organization.id) }
	let(:user1) { FactoryBot.create(:user, role_id: role.id) }
	let(:employee) { FactoryBot.create(:user, role_id: role1.id, email: "employee@joshsoftware.com", department_id: department_obj.id, organization_id: organization.id)}
	let(:resolver) { FactoryBot.create(:user, role_id: role2.id, email: "resolver@joshsoftware.com", department_id: department_obj.id, organization_id: organization.id)}

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
        do_request(create_params("Laptop Issue", "RAM issue", category.id, department_obj.id, "Request", user.id, ["image"]))
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200) 
        expect(response_data["message"]).to eq(I18n.t('tickets.success.create'))
      end
			example 'Set eta to ticket equal to sla of category on ticket creation' do
				do_request(create_params("Laptop Issue", "RAM issue", category.id, department_obj.id, "Request", user.id, nil))
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
				expect(Ticket.last.eta).to eq(Date.today + category.sla_unit.days)
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

			example 'Ticket reopened successfully with image' do
				@ticket.start
				@ticket.resolve
				@ticket.save
        do_request({
					"ticket_result": {
						"is_customer_satisfied": false,
						"rating": 2,
						"state_action": "reopen",
						"started_reason": "Not satisfied with your service",
						"asset_url": ["reopen"]
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

	put 'tickets/:id/update_ticket_progress' do
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
				do_request({ticket: { asset_url: ["image"] }})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.update'))
			end

			example 'Ticket updated successfully - added ETA' do
				do_request({ticket: { ETA: '04/01/2023'}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.update'))
			end

			example 'Ticket updated successfully - status from assigned to on_hold' do 
				do_request({ticket: { status: "on_hold"}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.update'))
			end

			example 'Ticket updated successfully - status from inprogress to on_hold' do 
				@ticket.start
				@ticket.save
				do_request({ticket: { status: "on_hold"}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.update'))
			end

			example 'Ticket updated successfully - status from for_approval to on_hold' do 
				@ticket.approve
				@ticket.save
				do_request({ticket: { status: "on_hold"}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.update'))
			end

			example 'Ticket updated successfully - status from on_hold to assigned' do 
				@ticket.hold
				@ticket.activate
				@ticket.save
				do_request({ticket: { status: "assigned"}})
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

			example 'Could not update ticket - invalid transition from on_hold to resolved' do
				@ticket.hold
				do_request({ticket: { status: 'resolved' }})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(422)
				expect(response_data["message"]).to eq(I18n.t('tickets.error.update'))
				expect(response_data["errors"]).to eq(response_data["errors"])
			end

			example 'Could not update ticket - invalid transition from closed to on_hold' do
				@ticket.start
				@ticket.resolve
				@ticket.close
				@ticket.save
				do_request({ticket: { status: 'on_hold' }})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(422)
				expect(response_data["message"]).to eq(I18n.t('tickets.error.update'))
				expect(response_data["errors"]).to eq(response_data["errors"])
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

	post 'tickets/bulk_update_ticket_progress' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
			@ticket1 = Ticket.create!(title: 'Laptop Issue', 
															 description: 'RAM Issue', 
															 category_id: category.id, 
															 department_id: department_obj.id, 
															 ticket_type: 'Request', 
															 resolver_id: user.id,
															 requester_id: user1.id,
															 organization_id: user.organization_id)
			@ticket2 = Ticket.create!(title: 'Laptop Issue', 
																description: 'RAM Issue', 
																category_id: category.id, 
																department_id: department_obj.id, 
																ticket_type: 'Request', 
																resolver_id: user.id,
																requester_id: employee.id,
																organization_id: user.organization_id)
			@department = Department.create!(name: "Test Department", organization_id: user.organization_id)
			@category = Category.create!(name: "Category for Test Department", department_id: @department.id)
			@resolver = User.create!(name: "testuser", role_id: role.id, email: "shefali@joshsoftware.com", 
															 department_id: @department.id, organization_id: user.organization_id)
		end

		context '200' do
			before do
				UserCategory.create!(user_id: @resolver.id, category_id: @category.id)
			end
			example 'Update bulk tickets with resolver_id' do
				do_request({ticket: { ticket_ids: [@ticket1.id, @ticket2.id], department_id: @department.id, 
															category_id: @category.id, resolver_id: @resolver.id }})
				response_data = JSON.parse(response_body)
				ticket1 = Ticket.find @ticket1.id
				ticket2 = Ticket.find @ticket2.id
				expect(ticket1.resolver_id).to eq(@resolver.id)
				expect(ticket2.resolver_id).to eq(@resolver.id)
				expect(response_data['message']).to eq(I18n.t('tickets.success.update'))
			end

			example 'Update status of tickets in bulk' do
				do_request({ticket: { ticket_ids: [@ticket1.id], status: 'inprogress' }})
				response_data = JSON.parse(response_body)
				ticket1 = Ticket.find @ticket1.id
				expect(ticket1.status).to eq('inprogress')
				expect(@ticket2.status).to eq('assigned')
				expect(response_data['message']).to eq(I18n.t('tickets.success.update'))
			end
		end

		context '422' do
			example 'Unable to update tickets because resolver does not belong to category of the department' do
				do_request({ticket: { ticket_ids: [@ticket1.id, @ticket2.id], department_id: @department.id, 
										category_id: @category.id, resolver_id: @resolver.id }})
				response_data = JSON.parse(response_body)
				expect(response_data['message']).to eq(I18n.t('tickets.error.update'))
				expect(response_data['errors']).to eq(I18n.t('tickets.error.resolver_not_associated_with_category'))
			end
		end

		context '401' do
			before do
				header 'Accept', 'application/vnd.providesk; version=1'
				header 'Authorization', JsonWebToken.encode({user_id: employee.id, email: employee.email, name: employee.name})
			end
			example 'Unauthorized user trying to update tickets' do
				do_request()
				expect(response_status).to eq(401)
			end
		end
	end

	put 'tickets/:id' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user1.id, email: user1.email, name: user1.name})
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
			example 'Ticket edited successfully - Department changed' do
				do_request({ticket: { department_id: @department.id}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.update'))
			end

			example 'Ticket edited successfully - Department and category changed' do
				do_request({ticket: { department_id: @department.id, category_id: @category.id}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.update'))
			end

			example 'Ticket edited successfully - Department and Resolver changed' do
				do_request({ticket: { department_id: @department.id, resolver_id: @resolver.id}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.update'))
			end

			example 'Ticket edited successfully - Title and description changed' do
				do_request({ticket: { title: 'Ticket edit', description: 'editing ticket'}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.update'))
			end

			example 'Ticket edited sccessfully - Ticket type changed' do
				do_request({ticket: { ticket_type: 'Complaint' }})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.update'))
			end

			example 'Ticket edited successfully - asset_url changed' do
				do_request({ticket: { asset_url: "image added"}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.update'))
			end
		end

		context '422' do
			let(:id) {@ticket.id}
			example 'Could not edit ticket - Resolver invalid' do
				do_request({ticket: { resolver_id: Faker::Base.numerify('#')}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(422)
				expect(response_data["message"]).to eq(I18n.t('tickets.error.update'))
				expect(response_data["errors"]).to eq(I18n.t('tickets.error.resolver'))
			end

			example 'Could not edit ticket - Category invalid' do
				do_request({ticket: { category_id: Faker::Base.numerify('#')}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(422)
				expect(response_data["message"]).to eq(I18n.t('tickets.error.update'))
				expect(response_data["errors"]).to eq(I18n.t('tickets.error.category'))
			end

			example 'Could not edit ticket - Department invalid' do
				do_request({ticket: { department_id: Faker::Base.numerify('#')}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(422)
				expect(response_data["message"]).to eq(I18n.t('tickets.error.update'))
				expect(response_data["errors"]).to eq(I18n.t('tickets.error.department'))
			end

			example 'Could not edit ticket - Status not in assigned state' do
				@ticket.start
				@ticket.save
				do_request({ticket: { ticket_type: 'Complaint'}})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(422)
				expect(response_data["message"]).to eq(I18n.t('tickets.error.update'))
				expect(response_data["errors"]).to eq(I18n.t('tickets.error.status'))
			end
		end

		context '401' do
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
			end

			let(:id) {@ticket.id}
			example 'Unauthorized user' do
				do_request({ ticket: { department_id: department_hr.id }})
				expect(response_status).to eq(401)
			end
		end
	end

	get 'tickets' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
			@ticket1 = Ticket.create!(title: 'Laptop Issue', 
															 description: 'RAM Issue', 
															 category_id: category.id, 
															 department_id: department_obj.id, 
															 ticket_type: 'Request', 
															 resolver_id: user.id,
															 requester_id: user1.id,
															 eta: Date.today + 3.days)
			@ticket2 = Ticket.create!(title: 'Laptop Issue', 
																description: 'RAM Issue', 
																category_id: category.id, 
																department_id: department_obj.id, 
																ticket_type: 'Request', 
																resolver_id: resolver.id,
																requester_id: user1.id,
																eta: Date.today + 3.days)
			 @ticket3 = Ticket.create!(title: 'LMouse Issue', 
																 description: 'RAM Issue', 
																 category_id: category.id, 
																 department_id: department_obj.id, 
																 ticket_type: 'Request', 
																 resolver_id: user.id,
																 requester_id: resolver.id,
																 eta: Date.today + 3.days)
		end

		context '200' do
			example 'show ticket without filters' do
				do_request()
				expect(response_status).to eq(200)
			end

			example 'show ticket with department filter' do
				do_request({department_id: department_obj.id})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data['data']).to eq([])
			end

			example 'show ticket with multiple filters - department and category' do
				do_request({department_id: department_obj.id, category_id: category.id})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data['data']).to eq([])
			end
		end

		context '200' do
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

		context '200' do
			before do
				header 'Accept', 'application/vnd.providesk; version=1'
				header 'Authorization', JsonWebToken.encode({user_id: resolver.id, email: resolver.email, name: resolver.name})
			end
			
			parameter :assigned_to_me, with_example: true
			parameter :created_by_me, with_example: true
			let(:assigned_to_me) { 'true' }
			let(:created_by_me) { 'true' }
			example 'show tickets with assigned_to_me and created_by_me filter for resolver' do
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data['data'].count).to eq(2)
			end
		end

		context '200' do
			before do
				header 'Accept', 'application/vnd.providesk; version=1'
				header 'Authorization', JsonWebToken.encode({user_id: resolver.id, email: resolver.email, name: resolver.name})
			end
			parameter :status, with_example: true
			let(:status) { 'inprogress' }
			example 'show tickets with other filters without assigned_to_me and created_by_me filter for resolver' do
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data['data']).to eq([])
			end
		end

		context '422' do
			example 'invalid filters' do
				do_request({department_id: Faker::Base.numerify('#')})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(422)
				expect(response_data["message"]).to eq(response_data["message"]) 
			end

			example 'Combination of valid and invalid filter' do
				do_request({department_id: department_obj.id, category_id: Faker::Base.numerify('#')})
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
															 requester_id: employee.id,
															 eta: Date.today + 3.days)
		end
		context '200' do
			let(:id) {@ticket.id}
			example 'Show ticket' do
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data['data']['ticket']['id']).to eq(@ticket.id)
				expect(response_data['data']['activities'].count).to eq(1)
			end

			example 'ask_for_update value set to true when eta < current time, last asked for update is nil' do
				@ticket.eta = Time.now.to_date - 1
				@ticket.save
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data['data']['ticket']['ask_for_update']).to eq(true)
			end

			example 'ask_for_update value set to true when eta < current time and last asked for update > 1 day' do
				@ticket.eta = Time.now.to_date - 1
				@ticket.asked_for_update_at = Time.now - 2.day
				@ticket.save
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data['data']['ticket']['ask_for_update']).to eq(true)
			end

			example 'ask_for_update value set to false when eta < current time and last asked for update < 1 day' do
				@ticket.eta = Time.now.to_date - 1
				@ticket.asked_for_update_at = Time.now + 2.hours
				@ticket.save
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data['data']['ticket']['ask_for_update']).to eq(false)
			end

			example 'ask_for_update value set to false when eta > current time' do
				@ticket.eta = Time.now.to_date + 2
				@ticket.save
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data['data']['ticket']['ask_for_update']).to eq(false)
			end

			example 'ask_for_update value set to false when eta is nil, last asked for update is nil updated_at time < 2 days' do
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data['data']['ticket']['ask_for_update']).to eq(false)
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

	get 'tickets/:id/ask_for_update' do
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
			example 'User asked for update' do
				do_request({ticket_link: 'testticketlink'})
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data["message"]).to eq(I18n.t('tickets.success.ask_for_update'))
			end	
		end
	end

	get 'tickets/timeline' do
		before do
			admin_role = Role.create!(name: Role::ROLE[:admin])
			@admin_user = User.create!(name: 'Admin', role_id: admin_role.id, email: 'admin@joshsoftware.com', 
															  organization_id: organization.id)
			testdept = Department.create!(name: "Learning and development", organization_id: organization.id)
			testcat = Category.create!(name: 'Traning', department_id: testdept.id, sla_unit: 3, sla_duration_type: 'Days',
																duration_in_hours: 72)
			@testuser = User.create!(name: 'Test', email: 'test@joshsoftware.com', role_id: role.id, department_id: testdept.id)
			@ticket1 = Ticket.create!(title: 'Laptop Issue', description: 'RAM Issue', category_id: category.id, ticket_type: 'Request',
															 department_id: department_obj.id, resolver_id: user.id, requester_id: employee.id)
			@ticket2 = Ticket.create!(title: 'Require Mouse', description: 'Touchpad is not working', resolver_id: user.id,
															 category_id: category.id, department_id: department_obj.id, ticket_type: 'Request',
															 requester_id: employee.id)
			@ticket3 = Ticket.create!(title: 'Require Laptop', description: 'Display damaged', resolver_id: user.id,
															 category_id: testcat.id, department_id: testdept.id, ticket_type: 'Request',
															 requester_id: employee.id)				
		end

		context '200' do
			before do
				header 'Accept', 'application/vnd.providesk; version=1'
				header 'Authorization', JsonWebToken.encode({user_id: @admin_user.id, email: @admin_user.email, name: @admin_user.name})
			end

			example 'Show overdue tickets to admin' do
				@ticket1.update(eta: (Time.now - 2.day).to_date)
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data['data']['overdue'].count).to eq(1)
			end

			example 'Show overdue tickets within two days to admin' do
				@ticket1.update(eta: Time.now.to_date)
				@ticket2.update(eta: (Time.now + 2.day).to_date)
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data['data']['overdue_in_two_days'].count).to eq(2)
			end

			example 'Show overdue tickets after two days to admin' do
				@ticket1.update(eta: (Time.now + 2.day).to_date)
				@ticket2.update(eta: (Time.now + 4.day).to_date)
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data['data']['overdue_after_two_days'].count).to eq(1)
			end
		end

		context '200' do
			before do
				header 'Accept', 'application/vnd.providesk; version=1'
				header 'Authorization', JsonWebToken.encode({user_id: @testuser.id, email: @testuser.email, name: @testuser.name})
			end

			example 'Show overdue tickets after two days to department_head' do
				@ticket1.update(eta: (Time.now + 2.day).to_date )
				@ticket3.update(eta: (Time.now + 4.day).to_date)
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_status).to eq(200)
				expect(response_data['data']['overdue_after_two_days'].count).to eq(1)
			end
		end

		context '401' do
			before do
				header 'Accept', 'application/vnd.providesk; version=1'
				header 'Authorization', JsonWebToken.encode({user_id: employee.id, email: employee.email, name: employee.name})
			end

			example 'Unauthorized user employee for listing overdue tickets' do
				do_request()
				expect(response_status).to eq(401)
			end
		end
	end

	get 'tickets/analytical_reports' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
			@ticket1 = Ticket.create!(title: 'Laptop Issue', 
															 description: 'RAM Issue', 
															 category_id: category.id, 
															 department_id: department_obj.id, 
															 ticket_type: 'Request', 
															 resolver_id: user.id,
															 requester_id: employee.id,
															 organization_id: user.organization_id)
			@ticket2 = Ticket.create!(title: 'Laptop Issue', 
																description: 'RAM Issue', 
																category_id: category.id, 
																department_id: department_obj.id, 
																ticket_type: 'Request', 
																resolver_id: user.id,
																requester_id: employee.id,
																organization_id: user.organization_id)
			@ticket2.update(created_at: Time.now - 13.months)
		end	

		context '200' do
			example 'Ticket count of organization status wise' do
				@ticket1.start
				@ticket1.save
				do_request()
				result = { 'total': 2, 'assigned': 1, 'inprogress': 1, 'for_approval': 0, 
									 'resolved': 0, 'closed': 0, 'rejected': 0, 'on_hold': 0 }.as_json
				response_data = JSON.parse(response_body)
				expect(response_data['data']['status_wise_organization_tickets']).to eq(result)
			end

			example 'Ticket count of organization department and status wise' do
				@ticket1.start
				@ticket1.resolve
				@ticket1.save
				do_request()
				result = { 
					"total": 2,
					"#{department_obj.id}": {
						'assigned': 1, 'inprogress': 0, 'for_approval': 0, 'resolved': 1,
						'closed': 0, 'rejected': 0, 'on_hold': 0
					},
					"#{department_hr.id}": {
						'assigned': 0, 'inprogress': 0, 'for_approval': 0, 'resolved': 0,
						'closed': 0, 'rejected': 0, 'on_hold': 0
					}
				}.as_json
				response_data = JSON.parse(response_body)
				expect(response_data['data']['status_wise_department_tickets']).to eq(result)
			end

			example 'Ticket count of organization status wise for last 12 months' do
				do_request()
				response_data = JSON.parse(response_body)
				expect(response_data['data']['month_and_status_wise_tickets']['total']).to eq(1)
			end
		end

		context '401' do
			before do
				header 'Accept', 'application/vnd.providesk; version=1'
				header 'Authorization', JsonWebToken.encode({user_id: employee.id, email: employee.email, name: employee.name})
			end

			example 'Unauthorized user employee for listing overdue tickets' do
				do_request()
				expect(response_status).to eq(401)
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
