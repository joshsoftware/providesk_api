class RenameRolesIdsAndOrganizationsId < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :roles_id, :role_id
    rename_column :users, :organizations_id, :organization_id
  end
end
