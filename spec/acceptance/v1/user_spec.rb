require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Users' do
  let!(:organization1) { FactoryBot.create(:organization, name: "Google", domain: ['gmail.com']) }
  let!(:organization2){ FactoryBot.create(:organization, name: "Josh", domain: ['joshsoftware.com'])}
  let!(:super_admin_role){ FactoryBot.create(:role, name: "super_admin") }
  let!(:department_head_role){ FactoryBot.create(:role, name: "department_head") }
  let!(:department) { FactoryBot.create(:department, name: "Finance", organization_id: organization1.id) }
  let!(:category) { FactoryBot.create(:category, name: "Loan", department_id: department.id)}
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
      example 'User role updated successfully' do
        do_request({user: { role: "department_head"}})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        expect(response_data["message"]).to eq(I18n.t('users.success.update'))
      end

      let!(:dept) { Department.create!(name: 'Learning and development', organization_id: organization1.id) }
      example 'User department updated successfully' do
        do_request({ user: { department_id: dept.id }})
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        expect(response_data["message"]).to eq(I18n.t('users.success.update'))
      end

      example 'Alloting a category to user' do
        do_request({ user: {department_id: department.id, category_ids: [category.id]} })
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        expect(user.user_categories.count).to eq(1)
        expect(response_data["message"]).to eq(I18n.t('users.success.update'))
      end

      let!(:cat1) { Category.create!(name: 'loan', department_id: dept.id) }
      let!(:cat2) { Category.create!(name: 'asset', department_id: dept.id) }
      example 'Alloting multiple categories to user' do
        do_request({ user: {department_id: dept.id, category_ids: [cat1.id, cat2.id]} })
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        expect(user.user_categories.count).to eq(2)
        expect(response_data["message"]).to eq(I18n.t('users.success.update'))
      end

      example 'Destroying previous user_categories and updating new ones' do
        do_request({ user: {department_id: department.id, category_ids: [category.id]} })
        expect(user.user_categories.count).to eq(1)
        do_request({ user: {department_id: dept.id, category_ids: [cat1.id, cat2.id]} })
        response_data = JSON.parse(response_body)
        expect(response_status).to eq(200)
        expect(user.user_categories.count).to eq(2)
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
        expect(response_status).to eq(401)
        expect(response_data["message"]).to eq("You are not authorized to access this page.")
        expect(response_data["authorization_failure"]).to be true
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
        expect(response_status).to eq(401)
        expect(response_data["message"]).to eq("You are not authorized to access this page.")
        expect(response_data["authorization_failure"]).to be true
      end
    end
  end
end