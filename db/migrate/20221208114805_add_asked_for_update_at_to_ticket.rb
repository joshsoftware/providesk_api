class AddAskedForUpdateAtToTicket < ActiveRecord::Migration[6.1]
  def change
    add_column :tickets, :asked_for_update_at, :datetime
  end
end
