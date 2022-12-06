class TicketSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :ticket_number, :status, :priority, :reason_for_update,
             :ticket_type, :resolved_at, :created_at, :category, :category_id, :department, :department_id,
             :resolver, :resolver_id, :requester, :requester_id, :updated_at, :permited_transitions, :eta
            

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

  def permited_transitions
    status = object.status
    case status
    when "assigned"
      ["inprogress", "for_approval", "rejected"]
    when "for_approval"
      ["inprogress", "rejected"]
    when "inprogress"
      ["resolved"]
    when "resolved"
      ["closed", "reopen"]
    else
      []
    end

  end
end
