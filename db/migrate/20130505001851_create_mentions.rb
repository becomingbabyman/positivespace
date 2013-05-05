class CreateMentions < ActiveRecord::Migration
  def change
    create_table :mentions do |t|
      t.string  :mentioner_type
      t.integer :mentioner_id
      t.string  :mentionable_type
      t.integer :mentionable_id
      t.datetime :created_at
    end

    add_index :mentions, ["mentioner_id", "mentioner_type"],   :name => "fk_mentions"
    add_index :mentions, ["mentionable_id", "mentionable_type"], :name => "fk_mentionables"

    add_column :users, :mentioners_count, :integer, default: 0
    add_index :users, :mentioners_count
  end
end
