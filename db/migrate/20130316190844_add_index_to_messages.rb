class AddIndexToMessages < ActiveRecord::Migration
  def change
	add_column :messages, :state, :string
	add_index :messages, :state
	add_index :messages, [:from_id, :to_id]
  end
end
