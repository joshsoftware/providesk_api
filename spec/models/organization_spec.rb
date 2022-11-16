require 'rails_helper'

RSpec.describe Organization, type: :model do
  before do
    Organization.destroy_all
    Organization.create!(name: "JoshSoftware",domain:["joshsoftware.com"])
  end
  
  context 'valid organisation' do
    before do
      @organization = Organization.new(name: Faker::Company.name)
    end
    it 'without domain name' do
      expect(@organization.valid?).to eq(true)
    end
    it 'with domain name' do
      @organization.domain = @organization.name.delete('- ,.!@$&_?/\'').downcase + '.com'
      expect(@organization.valid?).to eq(true)
    end
  end
  context 'invalid organisation' do
    before do
      @organization = Organization.new()
    end
    it 'without name' do
      expect(@organization.valid?).to eq(false)
    end
    it 'with duplicate name' do
      @organization.name = 'JoshSoftware'
      expect(@organization.valid?).to eq(false)
    end
  end
end
