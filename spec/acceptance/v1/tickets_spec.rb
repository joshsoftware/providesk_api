# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Tickets' do

	let!(:organization) { FactoryBot.create(:organization, name: "Josh") }
	let!(:department) { FactoryBot.create(:department, name: Faker::Name.name, organization_id: organization.id)}
	let!(:category) { FactoryBot.create(:category, name: "Hardware", priority: 0, department_id: department.id)}
	let!(:role) { FactoryBot.create(:role, name: 'super_admin')}
	let!(:role1) { FactoryBot.create(:role, name: 'employee')}
	let(:user) { FactoryBot.create(:user, role_id: role.id, email: "abcd@gmail.com") }
	let(:user1) { FactoryBot.create(:user, role_id: role.id, email: "pqrs@gmail.com") }
	let!(:ticket) { FactoryBot.create(:ticket, description: "For laptop with high graphics", ticket_number: "12", status: "assigned", priority: 0, department_id: department.id, category_id: category.id, ticket_type: "request", resolver_id: user.id, requester_id: user1.id) }

  post '/tickets' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
		end
		context '200' do
      example 'Ticket created successfully ' do
        do_request(create_params("Laptop Issue", "RAM issue", category.id, department.id, "request", user1.id))
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
					"department_id": department.id,
					"resolver_id": user.id }
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('tickets.error.create'))
      end
    end
  end

  get '/tickets/:ticket_id'do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
		end
		context '200' do
      example 'Ticket show success' do
        do_request({ticket_id: ticket.id})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
      end
    end

    context '404' do
      example 'Unable to show ticket' do
        do_request({ticket_id: Faker::Number.numerify('#')})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('tickets.error.show'))
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
