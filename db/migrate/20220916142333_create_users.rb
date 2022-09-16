class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, unique: true, null: false
      t.string :jwt_token, unique: true, null: false

      t.timestamps
    end

    add_foreign_key :users, :roles
    add_foreign_key :user, :organizations
  end
end
