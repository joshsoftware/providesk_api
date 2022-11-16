require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Sessions" do
  before do
    @organization1 = FactoryBot.create(:organization, name: 'josh', domain: ['joshsoftware.com'])
    @organization2 = FactoryBot.create(:organization, name: 'google', domain: ['gmail.com'])
    @employee_role = FactoryBot.create(:role, name: 'employee')
    @super_admin_role = FactoryBot.create(:role, name: 'super_admin')
    @admin_role = FactoryBot.create(:role, name: 'admin')
    @user = FactoryBot.create(:user, role_id: @employee_role.id)
    @super_admin_user = FactoryBot.create(:user, role_id: @super_admin_role.id)
    @admin_user = FactoryBot.create(:user, email: 'test@gmail.com', role_id: @admin_role.id, organization_id: @organization2.id)
    @domain = @user.email.split('@')[1]
  end

  post "/sessions" do
    parameter :email, "Email id of user"
    parameter :name, "Name of user"
    parameter :google_user_id, "google_user_id of user"
    context '200' do
      before do 
        header "Accept", "application/vnd.providesk; version=1"
      end
      example "Creating new user" do
        request = {
          user: {
            email: "aditya@"+@domain,
            name: "Aditya",
            google_user_id: 1
          }
        }
        do_request(request) 
        expect(status).to eq 200
      end

      example "Creating super admin which may or may not exist to an organization" do
        request = {
          user: { email: "superadmin@superadmin.com", 
                  name: "Super Admin", 
                  role_id: @super_admin_role.id 
                }
        }
        do_request(request)
        expect(status).to eq 200
      end

      example "Login existing user - super admin" do
        request = {
          user: {
            email: @super_admin_user.email,
            name: @super_admin_user.name,
            google_user_id: 2
          }
        }
        do_request(request) 
        response_data = JSON.parse(response_body)
        expect(status).to eq 200
        expect(response_data).to eq(response_data)
      end

      example "Login existing user - admin/employee" do
        request = {
          user: {
            email: @admin_user.email,
            name: @admin_user.name,
            google_user_id: 2
          }
        }
        do_request(request) 
        response_data = JSON.parse(response_body)
        expect(status).to eq 200
        expect(response_data).to eq(response_data)
      end
    end
    context '422' do
      before do 
        header "Accept", "application/vnd.providesk; version=1"
      end
      example "User email does not belong to domain" do
        request = {
          user: {
            email: "ad@jos.com",
            name: "Aditya",
            google_user_id: 1
          }
        }
        do_request(request) 
        expect(status).to eq 422
      end
    end
    context '422' do
      before do 
        header "Accept", "application/vnd.providesk; version=1"
      end
      example "Domain of company not added" do
        request = {
          user: {
            email: "ad@jos.com",
            name: "Aditya",
            google_user_id: 1
          }
        }
        do_request(request) 
        expect(status).to eq 422
      end
    end
  end

  get "/tickets/:id" do
    context '401' do
      before do
        header "Accept", "application/vnd.providesk; version=1"
        header 'Authorization', JsonWebToken.encode({user_id: @admin_user.id, email: @admin_user.email, name: @admin_user.name},
          {exp: Time.current})
      end
      let(:id) {0}
      example "Login Token Expired" do
        do_request()
        response_data = JSON.parse(response_body)
        expect(status).to eq(401)
        expect(response_data["message"]).to eq(I18n.t('session.expired'))
      end
    end
  end
end
