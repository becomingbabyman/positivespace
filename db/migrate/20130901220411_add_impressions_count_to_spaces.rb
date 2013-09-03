class AddImpressionsCountToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :impressions_count, :integer, default: 0, null: false
    add_index :spaces, :impressions_count
  end
end
