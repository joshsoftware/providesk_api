require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Organizations" do
  before do
    @user = FactoryBot.create(:user)
    @department = Department.find(@user.department_id)
    @organization = Organization.find(@user.organization_id)
  end
  get "/organizations/:id/departments" do
    context '200' do
      let(:id) { @organization.id }
      before do         
        payload = { user_id: @user.id,
          name: @user.name,
          email: @user.email,
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
                id: @department.id,
                name: @department.name
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
      let(:id) { @organization1.id }
      before do 
        @organization1 = FactoryBot.create(:organization, name: 'Josh3', domain: ["josh3.com"])
        payload = { user_id: @user.id,
          name: @user.name,
          email: @user.email,
          google_user_id: 2
        }
        token = JsonWebToken.encode(payload)
        header "Accept", "application/vnd.providesk; version=1"
        header "Authorization", token
      end
      
      example "User does not have access rights to the content" do
        expected_response = {
          message: I18n.t('organization.error.unauthorized_user')
        }.to_json
        do_request()
        expect(status).to eq 403
        response_body.should eq(expected_response)
      end
    end
  end
end
