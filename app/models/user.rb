class User < ApplicationRecord
  belongs_to :organization, optional: true
  belongs_to :role
  belongs_to :department, optional: true

  validates :email, uniqueness: true
  
  before_validation(on: :create) do
    domain = email.split('@')[1]
    self.role_id = role_id || 1
    self.organization_id = get_organization(domain)
  end

  def get_organization(organization_domain)
    id_to_domain_map = Organization.all.pluck(:id, :domain)
    id_to_domain_map.each do |id, domain|
      return id if domain.include?(organization_domain)
    end
  end
end
