class AddReasonForUpdateInActivityAndTicket < ActiveRecord::Migration[6.1]
  def change
    add_column :tickets, :reason_for_update, :string
    add_column :activities, :reason_for_update, :string
  end
end
