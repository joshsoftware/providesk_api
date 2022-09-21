require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'validations' do
    context 'when name contains data' do
      before do
        @role = Role.create(name: 'Admin')
      end
      it 'should validate data with no errors' do
        @role.save
        expect(@role.errors.full_messages).to be_empty
      end
    end
    context 'when name does not contain data' do
      before do
        @role = Role.create(name: '')
      end
      it 'should validate data errors' do
        @role.save
        expect(@role.errors.full_messages).to eq(["Name can't be blank"])
      end
    end
    context 'when name is not unique' do
      before do
        @role1 = Role.create(name: 'Admin')
        @role2 = Role.create(name: 'Admin')
      end
      it 'should validate data with errors' do
        @role.save
        expect(@role.errors.full_messages).to eq(['Name has already been taken'])
      end
    end
  end
end
