class User < ApplicationRecord
  belongs_to :organization, optional: true
  belongs_to :role
  belongs_to :department, optional: true
  has_many :tickets

  validates :name, presence: true
  validates :email,presence: true, uniqueness: true
  # validates_associated :tickets

  before_validation :assign_ids, on: [:create, :update]

  def is_super_admin?
    Role.find(self.role_id).name.eql?(Role::ROLE[:super_admin])
  end

  def is_admin?
    Role.find(self.role_id).name.eql?(Role::ROLE[:admin])
  end

  def is_department_head?
    Role.find(self.role_id).name.eql?(Role::ROLE[:department_head])
  end

  def is_employee?
    Role.find(self.role_id).name.eql?(Role::ROLE[:employee])
  end

  def assign_ids
    if email
      domain = email.split('@')[1]
      self.role_id = role_id || Role.find_by(name: 'employee').id
      self.organization_id = get_organization(domain)
    end
  end

  def get_organization(organization_domain)
    id_to_domain_map = Organization.all.pluck(:id, :domain)
    id_to_domain_map.each do |id, domain|
      return nil if domain == nil && is_super_admin?
      return id if domain.include?(organization_domain) 
    end
    if !is_super_admin?
      self.errors.add :organization, "can't be blank"
    end
  end
end
