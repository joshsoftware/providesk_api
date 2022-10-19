class AddConstraintsOnTickets < ActiveRecord::Migration[6.1]
  def change
    add_check_constraint :tickets, "status IN (0,1,2,3,4,5)", name: "status_check"
    add_check_constraint :tickets, "priority IN (0,1,2,3)", name: "priority_check"
    add_check_constraint :tickets, "ticket_type IN (0,1)", name: "type_check"

  end
end
