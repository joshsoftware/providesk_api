require 'rails_helper'

RSpec.describe User, type: :model do
  Organization.destroy_all
  Role.destroy_all
  Department.destroy_all
  User.destroy_all
  let(:organization) {Organization.create!(name: 'JoshSoftware',domain:['joshsoftware.com'])}
  let(:role) {Role.create!(name:'admin')}
  let(:department) {Department.create!(name: 'HR',organization_id: organization.id)}
  let(:role_super_admin) {Role.create!(name:'super_admin')}
  let(:category) {Category.create!(name: 'Payroll', department_id: department.id)}
  fake_name = Faker::Name.unique.name
  let(:user) {User.create(name: fake_name, 
                        email:   fake_name.downcase.split().join('.')+'@joshsoftware.com', 
                        role_id: role.id, 
                        department_id: department.id, 
                        organization_id: organization.id)}

  context 'valid user creation' do
    before do
      fake_name = Faker::Name.unique.name
      user = User.new(name: fake_name, 
                        email: fake_name.downcase.split().join('.')+'@joshsoftware.com', 
                        role_id: role.id, 
                        department_id: department.id, 
                        organization_id: organization.id)
    end
    it 'should pass without any errors' do
      expect(user.valid?).to eq(true)
    end
  end
  context 'invalid user creation' do
    before do
      fake_name = Faker::Name.unique.name
      user = User.new(name: fake_name, 
                        email: fake_name.downcase.split().join('.')+'@joshsoftware.com', 
                        role_id: role.id, 
                        department_id: department.id, 
                        organization_id: organization.id)
    end

    it 'should validate presence of existing role' do
      user.role_id = 0
      expect { user.save! }.to raise_exception
    end

    it 'should validate data for presence of name' do
      user.name = nil
      expect(user.valid?).to eq(false)
    end

    it 'should validate data for presence of email' do
      user.email = nil
      expect(user.valid?).to eq(false)
    end

    it 'should validate data for check of organization domain in the email' do
      user.email = "wrongemail@tablespace.com"
      expect(user.valid?).to eq(false)
    end
  end
  context 'valid updation' do
    it 'should pass without error updating the name' do
      user.name = "Changed name"
      expect(user.valid?).to eq(true)
    end
    it 'should pass without error updating the email with same domain' do
      user.email = "changedname@joshsoftware.com"
      expect(user.valid?).to eq(true)
    end
  end
  context 'invalid updation' do
    it 'should not pass updating the email with diffrent domain' do
      user.email = "changedname@tablespace.com"
      expect(user.valid?).to eq(false)
    end
  end
end
