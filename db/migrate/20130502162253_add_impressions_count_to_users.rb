class AddImpressionsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :impressions_count, :integer
    add_index :users, :impressions_count
  end
end
