require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do
  describe "Login API" do

    before do
      FactoryBot.create(:role, name: 'employee')
      FactoryBot.create(:role, name: 'admin')
      FactoryBot.create(:role, name: 'super_admin')
    end

    it "new user sign in" do
      @request.env["Accept"] = 'application/vnd.providesk; version=1'
      params = { user: { email: 'abc@josh.com', name: 'Name' } }
      FactoryBot.create(:organization, name: 'JOSH', domain: ['josh.com'])
      post :create, params: params, as: :json
      expect(response).to be_successful
      expect(JSON.parse(response.body)['message']).to eq(I18n.t('login.success'))
      expect(JSON.parse(response.body)['data'].keys).to eq(['auth_token', 'role'])
    end

    it "existing user sign in" do
      @user = FactoryBot.create(:user)
      @request.env["Accept"] = 'application/vnd.providesk; version=1'
      params = { user: { email: @user.email, name: @user.name } }
      post :create, params: params, as: :json
      expect(response).to be_successful
      expect(JSON.parse(response.body)['message']).to eq(I18n.t('login.success'))
      expect(JSON.parse(response.body)['data'].keys).to eq(['auth_token', 'role'])
    end

    it 'should raise error if Organization id missing for auto generated role i.e employee' do
      @request.env["Accept"] = 'application/vnd.providesk; version=1'
      params = { user: { email: 'abc@gmail.com', name: 'Name' } }
      post :create, params: params, as: :json
      expect(response.status).to eq(422)
      expect(JSON.parse(response.body)['errors']).to eq("Organization can't be blank")
    end
  end
end
