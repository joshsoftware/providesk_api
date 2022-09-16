class CreateOrganizations < ActiveRecord::Migration[6.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :domain, array: true, default: []

      t.timestamps
    end
  end
end
