class TicketSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :ticket_number, :status, :priority, :reason_for_update, :asset_url,
             :ticket_type, :resolved_at, :created_at, :category, :category_id, :department, :department_id, :eta,
             :resolver, :resolver_id, :requester, :requester_email, :requester_id, :updated_at, :permited_transitions,
             :ask_for_update
            

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

  def requester_email
    object.requester.email
  end

  def ask_for_update
    Ticket::ASK_FOR_UPDATE
  end

  def permited_transitions
    status = object.status
    role = @instance_options[:root]&.[](:role)
    case status
    when "assigned"
      ["inprogress", "for_approval", "rejected", "on_hold"]
    when "for_approval"
      ["inprogress", "rejected", "on_hold"]
    when "inprogress"
      ["resolved", "on_hold"]
    when "resolved"
      ["closed", "reopen"]
    when "on_hold"
      ["assigned", "for_approval", "inprogress"]
    else
      []
    end

  end
end
