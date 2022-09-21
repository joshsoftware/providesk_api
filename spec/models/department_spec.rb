require 'rails_helper'

RSpec.describe Department, type: :model do
  let(:organization1) {Organization.create(name: 'Josh Software', domain: ['@joshsoftware.com','@joshsoftware.digital'])}
  let(:organization2) {Organization.create(name: 'Table Space', domain: ['@tablespace.com'])}
  describe 'validations' do
    context 'when name contains data' do
      before do
        @department = Department.create(name: 'TAD', organization_id: organization1.id)
      end
      it 'should validate data with no errors' do
        @department.save
        expect(@department.errors.full_messages).to be_empty
      end
    end
    context 'when name does not contain data' do
      before do
        @department = Department.create(name: '', organization_id: organization1.id)
      end
      it 'should validate data with errors' do
        @department.save
        expect(@department.errors.full_messages).to eq(["Name can't be blank"])
      end
    end
    context 'when oraganization id contains data' do
      before do
        @department = Department.create(name: 'TAD', organization_id: organization1.id)
      end
      it 'should validate data with no errors' do
        @department.save
        expect(@department.errors.full_messages).to be_empty
      end
    end
    context 'when oraganization id does not contain data' do
      before do
        @department = Department.create(name: 'TAD', organization_id: nil)
      end
      it 'should validate data with errors' do
        @department.save
        expect(@department.errors.full_messages).to eq(["Organization must exist", "Organization can't be blank"])
      end
    end
    context 'when an organization has different depertments' do
      before do
        @department1 = Department.create(name: 'TAD', organization_id: organization1.id)
        @department2 = Department.create(name: 'Finance', organization_id: organization1.id)
      end
      it 'should validate data with no errors' do
        @department1.save
        @department2.save
        expect(@department2.errors.full_messages).to be_empty
      end
    end
    context 'when an organization has same depertments' do
      before do
        @department1 = Department.create(name: 'TAD', organization_id: organization1.id)
        @department2 = Department.create(name: 'TAD', organization_id: organization1.id)
      end
      it 'should validate data with errors' do
        @department1.save
        @department2.save
        expect(@department2.errors.full_messages).to eq(['Name has already been taken'])
      end
    end
    context 'when two organizations has same depertments' do
      before do
        @department1 = Department.create(name: 'TAD', organization_id: organization1.id)
        @department2 = Department.create(name: 'TAD', organization_id: organization2.id)
      end
      it 'should validate data with no errors' do
        @department1.save
        @department2.save
        expect(@department2.errors.full_messages).to be_empty
      end
    end
  end 
end
