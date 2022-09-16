class AddDepartmentInUser < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :departments, foreign_key: true
  end
end
