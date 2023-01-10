
require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Organizations' do
  let!(:organization) { FactoryBot.create(:organization, name: "google", domain: ["gmail.com"]) }
  let!(:role) { FactoryBot.create(:role, name: Role::ROLE[:super_admin]) }
  let!(:employee_role) { FactoryBot.create(:role, name: Role::ROLE[:employee]) }
  let!(:department_head_role) { FactoryBot.create(:role, name: Role::ROLE[:department_head]) }
	let!(:user) { FactoryBot.create(:user, role_id: role.id) }

  post '/organizations' do
		before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
		end
		context '200' do
      example 'Organization created successfully' do
        do_request({"organization": {
					"name": "Josh",
          "domain": ["joshsoftware.com", "joshdigital.com"]
          } 
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        expect(response_data["message"]).to eq(I18n.t('organizations.success.create'))
      end
    end

    context '422' do
      example 'Unable to create organization due to already existing name' do
        do_request({"organization": {
					"name": "google",
          "domain": ["gmail.com"]
          } 
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('organizations.error.create'))
        expect(response_data["errors"]). to eq("Name has already been taken")
      end

      example 'Unable to create organization due to blank name' do
        do_request({"organization": {
          "domain": ["joshsoftware.com", "joshdigital.com"]
          } 
				})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('organizations.error.create'))
        expect(response_data["errors"]).to eq("Name can't be blank")
      end

      example 'Unable to create organization due to invalid parameters' do
        do_request({"organization": {}})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["errors"]).to eq(I18n.t('missing_params'))
      end
    end
  end

  get '/organizations' do
    before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name})
		end
    
    context '200' do
      example 'Fetch organization list' do
        result = {
          total: 2,
          organizations:[
            {
              id: user.organization.id,
              name: user.organization.name
            },
            {
              id: organization.id,
              name: organization.name
            }
          ]
        }.as_json
        result['organizations'] = result['organizations'].sort_by{ |org| org['name'] }
        do_request()
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        expect(response_data["data"]).to eq(result)
      end
    end
  end

  get '/organizations/:id/departments' do
    before do
      @user = FactoryBot.create(:user)
      @department = Department.find(@user.department_id)
      @organization = Organization.find(@user.organization_id)
      payload = { user_id: @user.id, name: @user.name, email: @user.email, google_user_id: 1 }
      token = JsonWebToken.encode(payload)
      header "Accept", "application/vnd.providesk; version=1"
      header "Authorization", token
    end
    context '200' do
      let(:id) { @organization.id }
      example 'Listing departments for organization with valid user' do
        expected_response = {
          data:{
            total: 1,
            departments:[
              {
                id: @department.id,
                name: @department.name
              } 
            ]
          }
        }.to_json
        do_request()
        expect(status).to eq 200
        response_body.should eq(expected_response)
      end
    end

    context '401' do
      before do 
        @organization1 = FactoryBot.create(:organization, name: 'Josh3', domain: ["josh3.com"])
      end
      let(:id) { @organization1.id }
      example 'Unauthorized user' do
        do_request()
        expect(status).to eq 401
      end
    end

    context '404' do
      let(:id) { 0 }
      example 'Pass invalid organization id which does not exist in database' do
        do_request()
        response_data = JSON.parse(response_body)
        expect(status).to eq(404)
        expect(response_data["errors"]).to eq(I18n.t('record_not_found'))
      end
    end
  end

  get '/organizations/:id/users' do
    before do
      @user_with_no_dept = FactoryBot.create(:user, name: 'user_with_no_department', email: 'nodept@gmail.com', 
                                                    role_id: employee_role.id, department_id: nil)
      @user = FactoryBot.create(:user, email: 'user@gmail.com', role_id: department_head_role.id)
      payload = { user_id: @user.id, name: @user.name, email: @user.email, google_user_id: 1 }
      token = JsonWebToken.encode(payload)
      header "Accept", "application/vnd.providesk; version=1"
      header "Authorization", token
    end

    context '200' do
      let(:id) { organization.id }
      example 'List of users with no department' do
        do_request()
        response_data = JSON.parse(response_body)
        byebug
        expect(response_data['data']['total']).to eq(1)
      end
    end
  end
end

