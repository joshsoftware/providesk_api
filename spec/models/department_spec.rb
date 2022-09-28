require 'rails_helper'

RSpec.describe Department, type: :model do
  let(:organization1) {Organization.create(name: 'Josh Software', domain: ['@joshsoftware.com','@joshsoftware.digital'])}
  let(:organization2) {Organization.create(name: 'Table Space', domain: ['@tablespace.com'])}
  describe 'validations' do
    context 'for a valid department' do
      before do
        @department = Department.new(name: 'TAD', organization_id: organization1.id)
        @same_department_diff_organization = Department.new(name: 'TAD', organization_id: organization2.id)
        @same_oganization_diff_department = Department.new(name: 'Admin', organization_id: organization1.id)
      end
      it 'should validate data with no errors for adding a department in a organization' do
        @department.save
        expect(@department.errors.full_messages).to be_empty
      end
      it 'should validate data with no errors for adding same department in diffrent organization' do
        @department.save
        @same_department_diff_organization.save
        expect(@same_department_diff_organization.errors.full_messages).to be_empty
      end
      it 'should validate data with no errors for adding diffrent department in organization' do
        @department.save
        @same_oganization_diff_department.save
        expect(@same_department_diff_organization.errors.full_messages).to be_empty
      end
    end
    context 'for invalid departments' do
      before do
        @department = Department.new(name: 'TAD', organization_id: organization1.id)
        @same_department = Department.new(name: 'TAD', organization_id: organization1.id)        
      end
      it 'should validate data for presence of name' do
        @department.name = nil
        @department.save
        expect(@department.errors.full_messages).to eq(["Name can't be blank"])
      end
      it 'should validate data for presence of organization_id' do
        @department.organization_id = nil
        @department.save
        expect(@department.errors.full_messages).to eq(["Organization must exist", "Organization can't be blank"])
      end
      it 'should validate data for having same department in the organization' do
        @department.save
        @same_department.save
        expect(@same_department.errors.full_messages).to eq(['Name has already been taken'])
      end
    end
  end 
end
