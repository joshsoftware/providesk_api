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
  describe 'Set unique ticket_number on creation of new ticket' do
    context '200' do
      before do
        Ticket.create(title: Faker::Lorem.sentence(word_count:2), 
                            description: Faker::Lorem.paragraphs(number:1), 
                            ticket_number: 1,
                            ticket_type: 1,
                            resolver_id: user.id,
                            requester_id: user.id,
                            department_id: department.id,
                            category_id: category.id)
        @ticket = Ticket.first
      end
      it 'should validate data with no errors' do
        expect(@ticket.ticket_number).to eq("request-#{@ticket.id}")
      end
    end
  end
end
