class AddEtaToTickets < ActiveRecord::Migration[6.1]
  def change
    add_column :tickets, :eta, :date
  end
end
