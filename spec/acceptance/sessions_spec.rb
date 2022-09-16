require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Sessions" do
  before do
    FactoryBot.create(:role, name: 'employee')
    FactoryBot.create(:role, name: 'admin')
    FactoryBot.create(:role, name: 'super_admin')
  end

  post "/sessions" do
    parameter :email, "Email id of user"
    parameter :name, "Name of user"
    parameter :google_user_id, "google_user_id of user"
    context '200' do
      before do 
        FactoryBot.create(:organization, name: 'Josh', domain: ["josh.com"])
        @user1 = FactoryBot.create(:user, name: 'Aditya', email: "user1@josh.com")
        header "Accept", "application/vnd.providesk; version=1"
      end
      example "Creating new user" do
        request = {
          user: {
            email: "ad@josh.com",
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
            email: "user1@josh.com",
            name: "Aditya",
            google_user_id: 2
          }
        }
        do_request(request) 
        expect(status).to eq 200
      end
    end
    context '422' do
      before do 
        FactoryBot.create(:organization, name: 'Josh', domain: ["josh.com"])
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
        FactoryBot.create(:organization, name: 'Josh')
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
