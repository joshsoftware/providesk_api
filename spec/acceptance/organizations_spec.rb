require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Organizations" do
  let!(:organization) {FactoryBot.create(:organization, name: 'Josh4', domain: ["josh4.com"])}
  get "/organizations/:id" do
    context '200' do
      let(:id) { organization.id }
      before do 
        @department = FactoryBot.create(:department, name: 'TAD', organization_id: organization.id)
        employee = FactoryBot.create(:role, name: 'employee')
        user = FactoryBot.create(:user, name: Faker::Name.name, email: "user3@josh4.com", role_id: nil, organization_id: nil)
        payload = { user_id: user.id,
          name: user.name,
          email: user.email,
          google_user_id: 1
        }
        token = JsonWebToken.encode(payload)
        header "Accept", "application/vnd.providesk; version=1"
        header "Authorization", token
      end
      
      example "Listing departments for organization with valid user" do
        expected_response = {
          data:{
            total: 1,
            departments:[
              {
                name: @department.name,
                id: @department.id
              } 
            ]
          }
        }.to_json
        do_request()
        expect(status).to eq 200
        response_body.should eq(expected_response)
      end
    end
    context '403' do
      let(:id) { organization.id }
      before do 
        organization1 = FactoryBot.create(:organization, name: 'Josh3', domain: ["josh3.com"])
        employee = FactoryBot.create(:role, name: 'employee')
        user = FactoryBot.create(:user, name: Faker::Name.name, email: "user3@josh3.com", role_id: nil, organization_id: nil)
        payload = { user_id: user.id,
          name: user.name,
          email: user.email,
          google_user_id: 2
        }
        token = JsonWebToken.encode(payload)
        header "Accept", "application/vnd.providesk; version=1"
        header "Authorization", token
      end
      
      example "User does not have access rights to the content" do
        expected_response = {
          message: "User not registered to organization"
        }.to_json
        do_request()
        expect(status).to eq 403
        response_body.should eq(expected_response)
      end
    end
  end
end
