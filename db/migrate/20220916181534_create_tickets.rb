class CreateTickets < ActiveRecord::Migration[6.1]
  def change
    create_table :tickets do |t|
      t.string :title
      t.text :description
      t.string :ticket_number
      t.integer :status
      t.integer :priority
      t.integer :type
      t.datetime :resolved_at
      t.references :resolver, foreign_key:{to_table: :users}
      t.references :requester, foreign_key:{to_table: :users}
      t.references :department, foreign_key:{to_table: :departments}
      t.references :category, foreign_key:{to_table: :categories}

      t.timestamps
    end
  end
end
