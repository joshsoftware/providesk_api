require 'rails_helper'

RSpec.describe Api::V1::OrganizationsController, type: :model do
  let!(:organization) { FactoryBot.create(:organization, name: "google", domain: ["gmail.com"] ) }
  let!(:role) { FactoryBot.create(:role, name: 'super admin')}
	let!(:user) { FactoryBot.create(:user, role_id: role.id) }

  describe '#create' do
    context '200' do
      it 'Organization created successfully' do
        response_body = Organizations::V1::Create.new(params[:organization], user).call
        expect(response_body[:status]).to eq(true)
      end
    end

    context '400' do
      it 'Unable to create organization due to invalid params' do
        response_body = Organizations::V1::Create.new(invalid_params[:organization], user).call
        expect(response_body[:status]).to eq(false)
      end

      it 'Unable to create organization due to already existing name' do
        response_body = Organizations::V1::Create.new(organization, user).call
        expect(response_body[:status]).to eq(false)  
      end

      it 'Unable to create organization due to blank name' do
        response_body = Organizations::V1::Create.new(blank_name, user).call
        expect(response_body[:status]).to eq(false)  
      end
    end
  end

  private

  def params
    {
      "organization": {
        "name": "josh",
        "domain": ["joshsoftware.com", "joshdigital.com"]
      }
    }
  end

  def invalid_params
    {
      "organization": {
      }
    }
  end

  def blank_name
    {
      "organization": {
        "domain": ["joshsoftware.com", "joshdigital.com"]
      }
    }
  end
end