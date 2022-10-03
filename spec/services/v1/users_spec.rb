require 'rails_helper'

RSpec.describe Api::V1::OrganizationsController, type: :model do
  Organization.destroy_all
  Role.destroy_all
  User.destroy_all
  let!(:organization) { Organization.create(name: "google", domain: ["gmail.com"] ) }
  let!(:role) { Role.create(name: 'super_admin')}

  describe '#create' do
    it 'User created successfully' do
      response_body = Users::V1::Create.new(params).call
      expect(response_body[:status]).to eq(true)
    end

    it 'Unable to create user' do
      selected_params = params
      selected_params[:email] = nil

      response_body = Users::V1::Create.new(selected_params).call
      expect(response_body[:status]).to eq(false)
    end
  end

  describe '#update' do
    before do
      User.create(params)
    end

    it 'User updated successfully' do
      user = User.where(name: "Manu Goel")[0]
      updated_user = user
      updated_user.update(email: "manugoel96@joshsoftware.com")

      response_body = Users::V1::Update.new(updated_user, user, updated_user["id"].to_s).call
      expect(response_body[:status]).to eq(true)
    end

    it 'Unable to create user' do
      user = User.where(name: "Manu Goel")[0]
      updated_user = user
      updated_user.update(role_id: 0)

      response_body = Users::V1::Update.new(updated_user, user, updated_user["id"].to_s).call
      expect(response_body[:status]).to eq(false)
    end
  end

  describe '#show' do
    before do
      User.create(params)
    end

    it 'User shown successfully' do
      response_body = Users::V1::Destroy.new(User.first.id).call
      expect(response_body[:status]).to eq(true)
    end

    it 'Unable to show user' do
      response_body = Users::V1::Destroy.new(0).call
      expect(response_body[:status]).to eq(false)
    end
  end

  describe '#delete' do
    before do
      User.create(params)
    end

    it 'User deleted successfully' do
      response_body = Users::V1::Destroy.new(User.first.id).call
      expect(response_body[:status]).to eq(true)
    end

    it 'Unable to delete user' do
      response_body = Users::V1::Destroy.new(0).call
      expect(response_body[:status]).to eq(false)
    end
  end

  private

  def params
    {
      name: "Manu Goel",
      email: "manugoel@gmail.com",
      role_id: Role.find_by(name: 'super_admin').id
    }
  end
end