class ActivitySerializer < ActiveModel::Serializer
  attributes :id, :ticket_id, :assigned_from, :assigned_to, :reason_for_update, :asset_url,
             :get_description, :current_ticket_status, :previous_ticket_status, :created_at

  def get_description
    description = JSON.parse(object.description)
    description.join(', ')
  end
end
