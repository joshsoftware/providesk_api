class AddTicketInActivity < ActiveRecord::Migration[6.1]
  def change
    add_reference :activities, :ticket, foriegn_key: true
  end
end
