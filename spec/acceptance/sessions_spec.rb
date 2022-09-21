require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Sessions" do
  before do
    @employee = FactoryBot.create(:role, name: 'employee')
    @super_admin = FactoryBot.create(:role, name: 'super_admin')
    @user = FactoryBot.create(:user)
    @department = Department.find(@user.department_id)
    @organization = Organization.find(@user.organization_id)
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
      example "Login existing user" do
        request = {
          user: {
            email: @user.email,
            name: @user.name,
            google_user_id: 2
          }
        }
        do_request(request) 
        expect(status).to eq 200
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
end
