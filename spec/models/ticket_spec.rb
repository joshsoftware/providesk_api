require 'rails_helper'

RSpec.describe Ticket, type: :model do
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
                        email: fake_name.downcase.split().join('.')+'@joshsoftware.com', 
                        role_id: role.id, 
                        department_id: department.id, 
                        organization_id: organization.id)}
  describe 'validations' do
    context 'a valid ticket' do
      before do
        @ticket = Ticket.new(title: Faker::Lorem.sentence(word_count:2), 
                            description: Faker::Lorem.paragraphs(number:1), 
                            ticket_number: 1,
                            ticket_type: 0,
                            resolver_id: user.id,
                            requester_id: user.id,
                            department_id: department.id,
                            category_id: category.id)
      end
      it 'should validate data with no errors' do
        expect(@ticket.valid?).to eq(true)
      end
    end
    context 'a invalid ticket' do
      before do
        @ticket = Ticket.new(title: Faker::Lorem.sentence(word_count:2), 
                            description: Faker::Lorem.paragraphs(number:1), 
                            ticket_number: 1,
                            ticket_type: 0,
                            resolver_id: user.id,
                            requester_id: user.id,
                            department_id: department.id,
                            category_id: category.id)
      end
      it 'should validate data for presence of title' do
        @ticket.title = nil
        expect(@ticket.valid?).to eq(false)
      end
      it 'should validate data for presence of description' do
        @ticket.description = nil
        expect(@ticket.valid?).to eq(false)
      end
      # it 'should validate data for presence of ticket number' do
      #   @ticket.ticket_number = nil
      #   expect(@ticket.valid?).to eq(false)
      # end
      it 'should validate data for presence of ticket type' do
        @ticket.ticket_type = nil
        expect(@ticket.valid?).to eq(false)
      end
      it 'should validate data for presence of ticket resolver' do
        @ticket.resolver_id = nil
        expect(@ticket.valid?).to eq(false)
      end
      it 'should validate data for presence of ticket requester' do
        @ticket.requester_id = nil
        expect(@ticket.valid?).to eq(false)
      end
      it 'should validate data for presence of ticket department_id' do
        @ticket.department_id = nil
        expect(@ticket.valid?).to eq(false)
      end
      it 'should validate data for presence of ticket catergory_id' do
        @ticket.category_id = nil
        expect(@ticket.valid?).to eq(false)
      end
      it 'should validate data for foreign key of resolver_id' do
        @ticket.resolver_id = 0
        expect(@ticket.valid?).to eq(false)
      end
      it 'should validate data for foreign key of requester_id' do
        @ticket.requester_id = 0
        expect(@ticket.valid?).to eq(false)
      end
      it 'should validate data for presence of department_id' do
        @ticket.department_id = 0
        expect(@ticket.valid?).to eq(false)
      end
      it 'validation in enums' do
        error = assert_raises ArgumentError do
          @ticket.status = 7
        end
        error
      end
    end
  end
end
