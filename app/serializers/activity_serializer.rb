class ActivitySerializer < ActiveModel::Serializer
  attributes :id, :ticket_id, :assigned_from, :assigned_to,
             :description, :current_ticket_status, :asset_url
end
