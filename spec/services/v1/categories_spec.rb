require 'rails_helper'

RSpec.describe Api::V1::CategoriesController, type: :model do
  let!(:organization) { FactoryBot.create(:organization, name: "google", domain: ["gmail.com"] ) }
  let!(:department) { FactoryBot.create(:department, name: "Talent and aquisition", organization_id: organization.id)}
  let!(:category) { FactoryBot.create(:category, name: "Upskilling", priority: 0, department_id: department.id) }
  let!(:role) { FactoryBot.create(:role, name: 'super admin')}
	let!(:user) { FactoryBot.create(:user, role_id: role.id) }

  describe '#create' do
    context '200' do
      it 'Categories created successfully' do
        response_body = Categories::V1::Create.new(params[:categories]).call
        expect(response_body[:status]).to eq(true)
      end
    end

    context '400' do
      it 'Unable to create category due to invalid params' do
        response_body = Categories::V1::Create.new({}).call
        expect(response_body[:status]).to eq(false)
      end

      it 'Unable to create category due to already existing name' do
        response_body = Categories::V1::Create.new(category).call
        expect(response_body[:status]).to eq(false)  
      end

      it 'Unable to create category due to blank name' do
        response_body = Categories::V1::Create.new({"priority": 0, "department_id": 1}).call
        expect(response_body[:status]).to eq(false)  
      end

      it 'Unable to create category due to blank department' do
        response_body = Categories::V1::Create.new({"name": "Knowledge management", "priority": 0}).call
        expect(response_body[:status]).to eq(false)  
      end
    end
  end

  private

  def params
    {
      "categories": {
        "name": "Knowledge management",
        "priority": 0,
        "department_id": department.id
      }
    }
  end
end