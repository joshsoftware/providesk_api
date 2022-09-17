# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Departments' do
  before do
    login_user
  end


  post '/departments' do
    context '200' do
      example 'Create a department successfully ' do
        request = { name: "Varun" , organization_id: @org.id }
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


      example 'Unable to create department as department already exisits' do
        request = { name: "My Dept" , organization_id: @org.id }
        do_request(request)

        new_request = { name: "My Dept" , organization_id: @org.id }
        do_request(new_request)
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq("Name has already been taken")
      end
    end
  end
end
