class AddDefaultValueToPriorityInTicket < ActiveRecord::Migration[6.1]
  def change
    change_column_default :tickets, :priority, to: 0
    change_column_default :tickets, :status, to: 0
  end
end
