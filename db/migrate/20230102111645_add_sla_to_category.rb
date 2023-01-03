class AddSlaToCategory < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :sla_unit, :integer
    add_column :categories, :sla_duration_type, :string
    add_column :categories, :duration_in_hours, :integer
  end
end
