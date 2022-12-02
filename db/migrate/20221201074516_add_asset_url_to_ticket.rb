class AddAssetUrlToTicket < ActiveRecord::Migration[6.1]
  def change
    add_column :tickets, :asset_url, :string, array: true, default: []
  end
end
