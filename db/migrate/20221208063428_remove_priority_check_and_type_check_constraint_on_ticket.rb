class RemovePriorityCheckAndTypeCheckConstraintOnTicket < ActiveRecord::Migration[6.1]
  def change
    remove_check_constraint :tickets, name: "type_check"
    remove_check_constraint :tickets, name: "priority_check"
  end
end
