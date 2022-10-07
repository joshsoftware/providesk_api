class TicketSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :ticket_number, :status, :priority, 
             :ticket_type, :resolved_at, :created_at, :updated_at, :category, :department, 
             :resolver, :requester, :permited_events
            

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

  def permited_events
    status = object.status
    case status
    when "assigned"
      ["start", "approve", "reject"]
    when "for_approval"
      ["start", "reject"]
    when "inprogress"
      ["resolve"]
    when "resolved"
      ["close", "reopen"]
    else
      []
    end

  end
end
