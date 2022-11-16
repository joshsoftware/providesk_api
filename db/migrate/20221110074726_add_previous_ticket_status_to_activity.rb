class AddPreviousTicketStatusToActivity < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :previous_ticket_status, :integer
  end
end
