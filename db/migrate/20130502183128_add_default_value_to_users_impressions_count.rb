class AddDefaultValueToUsersImpressionsCount < ActiveRecord::Migration
  def change
	change_column :users, :impressions_count, :integer, :default => 1
  end
end
