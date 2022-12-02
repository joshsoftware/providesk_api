class ChangeAssetUrlFromStringToArrayInActivity < ActiveRecord::Migration[6.1]
  def change
    change_column :activities, :asset_url, :string, array: true, default: [], using: "(string_to_array(asset_url, ','))"
  end
end