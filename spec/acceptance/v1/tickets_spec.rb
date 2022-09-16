# frozen_string_literal: true

require 'acceptance_helper'
require 'rails_helper'

resource 'Ticket Details' do
  set_header

  let!(:ticket) { create(:ticket) }

  post '/tickets' do
    
    describe '#create' do
      example 'Success - Ticket created successfully ' do
        do_request
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
      end
    end
  end
end
