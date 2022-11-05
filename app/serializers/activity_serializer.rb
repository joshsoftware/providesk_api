class ActivitySerializer < ActiveModel::Serializer
  attributes :id, :ticket_id, :assigned_from, :assigned_to, :reason_for_update,
             :description, :current_ticket_status, :asset_url, :created_at
end
