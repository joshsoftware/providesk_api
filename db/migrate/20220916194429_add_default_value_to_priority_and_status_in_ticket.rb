class AddDefaultValueToPriorityAndStatusInTicket < ActiveRecord::Migration[6.1]
  def change
    change_column_default :tickets, :status, from: nil, to: 0
    change_column_default :tickets, :priority, from: nil, to: 0
  end
end
