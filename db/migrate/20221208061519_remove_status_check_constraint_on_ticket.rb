class RemoveStatusCheckConstraintOnTicket < ActiveRecord::Migration[6.1]
  def change
    remove_check_constraint :tickets, name: "status_check"
  end
end
