# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Departments' do
  before do
<<<<<<< HEAD
    @user = FactoryBot.create(:user)
    @org = @user.organization
    @department = FactoryBot.create(:department, name: 'TAD', organization_id: @org.id)
    @some_other_organization = FactoryBot.create(:organization, name: "SomeOther", domain: "someother.com")
    @some_other_department = FactoryBot.create(:department, name: 'TAD', organization_id: @some_other_organization.id)
    payload = { user_id: @user.id, name: @user.name, email: @user.email, google_user_id: 1 }
=======
    user = FactoryBot.create(:user)
    @org = user.organization
    @department = FactoryBot.create(:department, name: 'TAD', organization_id: @org.id)
    @some_other_organization = FactoryBot.create(:organization, name: "SomeOther", domain: "someother.com")
    @some_other_department = FactoryBot.create(:department, name: 'TAD', organization_id: @some_other_organization.id)
    payload = { user_id: user.id, name: user.name, email: user.email, google_user_id: 1 }
>>>>>>> ce959cea4b92b247d95102c38114193dee2906f1
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
<<<<<<< HEAD
  get 'departments/:department_id/users' do
    context '200' do
      let!(:department_id){ @user.department_id }
      before do
        @category = FactoryBot.create(:category, name: 'TAD1', priority:1, department_id: @department.id)
      end
      example 'List users of department successfully' do
        expected_response = {
          data:{
            total: 1,
            users: [
              {
                id: @user.id,
                name: @user.name
=======

  get 'departments/:id/categories' do
    context '200' do
      let!(:id){ @department.id }
      before do
        @category = FactoryBot.create(:category, name: 'TAD1', priority:1, department_id: @department.id)
      end
      example 'List categories of department successfully' do
        expected_response = {
          data:{
            total: 1,
            categories: [
              {
                id: @category.id,
                name: @category.name
>>>>>>> ce959cea4b92b247d95102c38114193dee2906f1
              }
            ]
          }
        }.to_json
        do_request()
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        response_body.should eq(expected_response)
      end
    end
    context '422' do
      let!(:id){ 0 }

      example 'Pass invalid department id which does not exist on database' do
        expected_response = {
          message: I18n.t('department.error.invalid_department_id')
        }.to_json
        do_request()
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        response_body.should eq(expected_response)
      end
    end
    context '403' do
<<<<<<< HEAD
      let!(:department_id){ @some_other_department.id }

      example 'Pass invalid department id of organization to which user is not registered' do
=======
      let!(:id){ @some_other_department.id }

      example 'Pass invalid department id of wrong organization to which user is not registered' do
>>>>>>> ce959cea4b92b247d95102c38114193dee2906f1
        expected_response = {
          message: I18n.t('organization.error.unauthorized_user')
        }.to_json
        do_request()
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(403)
        response_body.should eq(expected_response)
      end
    end
  end
end
