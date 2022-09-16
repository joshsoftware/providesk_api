class RemoveNotNullJwtTokenInUsers < ActiveRecord::Migration[6.1]
  def change
    change_column :users, :jwt_token, :string, null: false
  end
end
