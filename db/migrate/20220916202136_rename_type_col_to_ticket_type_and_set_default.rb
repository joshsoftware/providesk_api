class RenameTypeColToTicketTypeAndSetDefault < ActiveRecord::Migration[6.1]
  def change
    rename_column :tickets, :type, :ticket_type
    change_column_default :tickets, :priority, from: nil, to: 1
  end
end
