class User < ApplicationRecord
  belongs_to :organization, optional: true
  belongs_to :role
  belongs_to :department, optional: true
  has_many :tickets

  validates :name, presence: true
  validates :email,presence: true, uniqueness: true
  # validates_associated :tickets

  before_validation(on: :create) do
    domain = email.split('@')[1]
    self.role_id = role_id || Role.find_by(name: 'employee').id
    self.organization_id = get_organization(domain)
  end

  def get_organization(organization_domain)
    id_to_domain_map = Organization.all.pluck(:id, :domain)
    id_to_domain_map.each do |id, domain|
      return id if domain.include?(organization_domain)
    end
    
    if !Role.find(self.role_id).name.eql?('super_admin')
      self.errors.add :organization, "can't be blank"
    end
  end
end
