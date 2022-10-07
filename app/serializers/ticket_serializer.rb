class TicketSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :ticket_number, :status, :priority, 
             :ticket_type, :resolved_at, :created_at, :updated_at, :category, :department, 
             :resolver, :requester
            

  def category
    object.category.name
  end

  def department
    object.department.name
  end

  def requester
    object.requester.name
  end

  def resolver
    object.resolver.name
  end
end
