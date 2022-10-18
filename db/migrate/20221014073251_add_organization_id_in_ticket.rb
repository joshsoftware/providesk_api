class AddOrganizationIdInTicket < ActiveRecord::Migration[6.1]
  def change
    add_column :tickets, :organization_id, :integer
  end
end
