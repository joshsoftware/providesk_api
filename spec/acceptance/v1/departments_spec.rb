# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Departments' do
  let!(:role) { FactoryBot.create(:role, name: 'admin')}
  let!(:role1) { FactoryBot.create(:role, name: 'employee')}
	let!(:user) { FactoryBot.create(:user, role_id: role.id) }
  before do
    @org = user.organization
    @department = FactoryBot.create(:department, name: 'TAD', organization_id: @org.id)
    @some_other_organization = FactoryBot.create(:organization, name: "SomeOther", domain: "someother.com")
    @some_other_department = FactoryBot.create(:department, name: 'TAD', organization_id: @some_other_organization.id)
    header 'Accept', 'application/vnd.providesk; version=1'
    header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
  end
  let!(:user1) { FactoryBot.create(:user, role_id: role1.id, department_id: @department.id)}

  post '/departments' do
    context '200' do
      example 'Create a department successfully ' do
        request = {
          department: 
          { name: Faker::Name.name , organization_id: @org.id }
        }
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
        expect(response_data["errors"]).to eq(I18n.t('missing_params'))
      end


      example 'Fail to create a department with the same name' do
        dept_name = "My Dept"
        request = { department: { name: dept_name , organization_id: @org.id } }
        do_request(request)
        new_request = { department: { name: dept_name , organization_id: @org.id } }
        do_request(new_request)
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq("Name has already been taken")
      end
    end
  end

  get 'departments/:id/users' do
    context '200' do
      before do
        @employee_id = Role.create(name: 'employee').id
        @category = FactoryBot.create(:category, name: 'TAD1', priority:1, department_id: @department.id)
        @user_with_no_department = FactoryBot.create(:user, name: "NoDeptUser", email: "nodeptuser@#{@org.domain[0]}", organization_id: @org.id, role_id: @employee_id )
      end
      context 'user with department' do
        let!(:id){ user1.department_id }
        example 'List users of department successfully' do
          expected_response = {
            data:{
              total: 1,
              users: [
                {
                  id: user1.id,
                  name: user1.name,
                  department_id: user1.department_id,
                  role: user1.role.name
                }
              ]
            }
          }.to_json
          do_request()
          response_data = JSON.parse(response_body)
          # response_body = response_data["data"]["users"][0].except("department_id","role").to_json
          expect(response_status).to eq(200)

          response_body.should eq(expected_response)
        end
      end
      context 'user with no department' do
        let!(:id){ @user_with_no_department.department_id }
        example 'List users of with unassigned department' do
          expected_response = {
            data:{
              total: 1,
              users: [
                {
                  id: @user_with_no_department.id,
                  name: @user_with_no_department.name,
                  department_id: @user_with_no_department.department_id,
                  role: @user_with_no_department.role.name
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
    end
    context '422' do
      let!(:id){ 0 }
      example 'Pass invalid department id which does not exist on database' do
        expected_response = {
          errors: "Record not found"
        }.to_json
        do_request()
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(404)
        response_body.should eq(expected_response)
      end
    end
    context '401' do
      let!(:id){ @some_other_department.id }
      example 'Pass invalid department id of organization to which user is not registered' do
        expected_response = {
          message: "You are not authorized to access this page.",
          authorization_failure: true
        }.to_json
        do_request()
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(401)
        response_body.should eq(expected_response)
      end
    end
  end
  
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
    context '404' do
      let!(:id){ 0 }
      example 'Pass invalid department id which does not exist on database' do
        expected_response = {
          errors: "Record not found"
        }.to_json
        do_request()
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(404)
        response_body.should eq(expected_response)
      end
    end
    context '403' do
      let!(:id){ @some_other_department.id }
      example 'Pass invalid department id of wrong organization to which user is not registered' do
        expected_response = {
          message: "You are not authorized to access this page.",
          authorization_failure: true
        }.to_json
        do_request()
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(401)
        response_body.should eq(expected_response)
      end
    end
  end
end
