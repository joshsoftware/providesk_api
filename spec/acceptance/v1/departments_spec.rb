# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Departments' do
  header 'Accept', 'application/vnd.providesk; version=1'

  post '/departments' do
    context '200' do
      example 'Create a department successfully ' do
        request = { name: "Varun" }
        do_request(request)
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        expect(response_data["message"]).to eq(I18n.t('department.success.create'))
      end
    end
  end
end
