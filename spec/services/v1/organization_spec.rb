require 'rails_helper'

RSpec.describe Api::V1::OrganizationsController, type: :model do
  let!(:organization) { FactoryBot.create(:organization, name: "google", domain: ["gmail.com"] ) }
  let!(:role) { FactoryBot.create(:role, name: 'super admin')}
	let!(:user) { FactoryBot.create(:user, role_id: role.id) }

  describe '#create' do
    it 'Organization created successfully' do
      response_body = Organizations::V1::Create.new(params, user).call
      expect(response_body[:status]).to eq(true)
    end

    it 'Unable to create organization' do
      response_body = Organizations::V1::Create.new(organization, user).call
      expect(response_body[:status]).to eq(false)  
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
end