class ActivitySerializer < ActiveModel::Serializer
  attributes :id, :ticket_id, :assigned_from, :assigned_to, :reason_for_update, :asset_url,
             :description, :current_ticket_status, :previous_ticket_status, :created_at
end
