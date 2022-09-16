class RemoveJwtTokenColFromUser < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :jwt_token
  end
end
