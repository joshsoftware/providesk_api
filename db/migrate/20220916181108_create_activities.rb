class CreateActivities < ActiveRecord::Migration[6.1]
  def change
    create_table :activities do |t|
      t.string :assigned_from, null: false
      t.string :assigned_to, null: false
      t.string :description
      t.string :asset_url
      t.integer :current_ticket_status, default: 0

      t.timestamps
    end
  end
end
