require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Users' do
  let!(:organization1) { FactoryBot.create(:organization, name: "Google", domain: ['gmail.com']) }
  let!(:organization2){ FactoryBot.create(:organization, name: "Josh", domain: ['joshsoftware.com'])}
  let!(:super_admin_role){ FactoryBot.create(:role, name: "super_admin") }
  let!(:department_head_role){ FactoryBot.create(:role, name: "department_head") }
  let!(:department) { FactoryBot.create(:department, name: "Finance", organization_id: organization1.id) }
  let!(:super_admin) { FactoryBot.create(:user, name: "Super Admin", email: "superadmin@email.com", role_id: super_admin_role.id) }
  let!(:department_head) { FactoryBot.create(:user, name: "Dept_head", email: "dept_head@gmail.com", role_id: department_head_role.id, 
                                                    department_id: department.id, organization_id: organization1.id)}
  let!(:employee) { FactoryBot.create(:role, name: "employee") }
  let!(:user) { FactoryBot.create(:user, name: "faker", email: "faker@gmail.com", department_id: department.id,
                                         role_id: employee.id) }
  put '/users/:id' do
    before do
			header 'Accept', 'application/vnd.providesk; version=1'
			header 'Authorization', JsonWebToken.encode({user_id: super_admin.id, email: super_admin.email, name: super_admin.name})
		end
    context '200' do
      let(:id) { user.id }
      example 'User updated successfully ' do
        do_request({user: { role: "department_head"}})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        expect(response_data["message"]).to eq(I18n.t('users.success.update'))
      end
    end
    context '422' do
      before do
        header 'Accept', 'application/vnd.providesk; version=1'
			  header 'Authorization', JsonWebToken.encode({user_id: user.id, email: user.email, name: user.name} )
      end
      let(:id) { user.id }
      example 'Could not update user - Invalid Role' do
        do_request({user: { role: "department_head"}})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('users.error.update'))
        expect(response_data["errors"]).to eq(I18n.t('users.error.role'))
      end
    end
    context '422' do
      before do
        header 'Accept', 'application/vnd.providesk; version=1'
			  header 'Authorization', JsonWebToken.encode({user_id: department_head.id, email: department_head.email, name: department_head.name} )
      end
      let(:id) { user.id }
      example 'Does not belong to organization/department' do
        user.update!(email: "faker@joshsoftware.com", department_id: nil)
        do_request({user: { role: "department_head"}})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(422)
        expect(response_data["message"]).to eq(I18n.t('users.error.update'))
        expect(response_data["errors"]).to eq(I18n.t('users.error.organization'))
      end
    end
  end
end