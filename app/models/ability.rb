class Ability
  include CanCan::Ability

  def initialize(user)
    user.blank? ? return : (@user = user)
    department_head_abilities if user.is_department_head?
    employee_abilities if user.is_employee?
    admin_abilities if user.is_admin?
    super_admin_abilities if user.is_super_admin?
  end

  def super_admin_abilities
    can [:create, :departments], Organization
    can [:create], Department
    can [:update], User
  end

  def admin_abilities
    can [:users, :departments], Organization do |organization|
      @user.organization_id == organization.id
    end
    can [:create, :categories, :users], Department, organization_id: @user.organization_id
    can [:create], Category do |category|
      @user.organization_id == category.department.organization_id
    end
    can [:read, :show, :update, :index, :reopen], Ticket, organization_id: @user.organization_id
    can [:update], User do |user|
      user.organization_id == @user.organization_id
    end
  end

  def department_head_abilities
    can [:categories, :users], Department do |department|
      @user.department_id == department.id
    end
    can [:create], Category, department_id: @user.department_id
    can [:create, :show, :index, :reopen, :update], Ticket, department_id: @user.department_id
    can [:update], User do |user|
      (user.department_id == @user.department_id) || (user.department_id.nil? && user.organization_id == @user.organization_id)
    end
  end

  def employee_abilities
    can [:create, :index], Ticket
    can [:show, :reopen], Ticket do |ticket|
      ticket.resolver_id == @user.id || ticket.requester_id == @user.id
    end
  end
end
