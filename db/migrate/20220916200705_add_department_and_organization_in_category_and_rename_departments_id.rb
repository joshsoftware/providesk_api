class AddDepartmentAndOrganizationInCategoryAndRenameDepartmentsId < ActiveRecord::Migration[6.1]
  def change
    add_reference :categories, :department, foreign_key: true
    add_reference :departments, :organization, foreign_key: true
    rename_column :users, :departments_id, :department_id
  end
end
