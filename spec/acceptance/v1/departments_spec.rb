# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Departments' do
  before do
    user = FactoryBot.create(:user)
    @org = user.organization
    payload = { user_id: user.id, name: user.name, email: user.email, google_user_id: 1 }
    token = JsonWebToken.encode(payload)
    header 'Accept', 'application/vnd.providesk; version=1'
    header 'Authorization', token
  end


  post '/departments' do
    context '200' do
      example 'Create a department successfully ' do
        request = { name: Faker::Name.name , organization_id: @org.id }
        do_request(request)
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        expect(response_data["message"]).to eq(I18n.t('department.success.create'))
      end
    end

    context '422' do
      example 'Unable to create department due to invalid params' do
        request = {}
        do_request(request)
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('department.invalid_params'))
      end


      example 'Fail to create a department with the same name' do
        dept_name = "My Dept"
        request = { name: dept_name , organization_id: @org.id }
        do_request(request)

        new_request = { name: dept_name , organization_id: @org.id }
        do_request(new_request)
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq("Name has already been taken")
      end
    end
  end
end
