require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'validations' do
    context 'valid role' do
      before do
        @role = Role.new(name: 'Admin')
      end
      it 'should validate data with no errors' do
        @role.save
        expect(@role.errors.full_messages).to be_empty
      end
    end
    context 'invalid role' do
      before do
        @role = Role.new(name: 'Admin')
        @duplicate_role = Role.new(name: 'Admin')
      end
      it 'should validate for empty role' do
        @role.name = nil
        @role.save
        expect(@role.errors.full_messages).to eq(["Name can't be blank"])
      end
      it 'should validate for duplicate role' do
        @role.save
        @duplicate_role.save
        expect(@duplicate_role.errors.full_messages).to eq(['Name has already been taken'])
      end
    end
  end
end
