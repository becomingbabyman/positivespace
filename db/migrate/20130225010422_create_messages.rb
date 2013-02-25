class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :from_id
      t.integer :to_id
      t.string :from_email
      t.string :to_email
      t.string :embed_url
      t.text :embed_data
      t.text :body

      t.timestamps
    end
    add_index :messages, :from_id
    add_index :messages, :to_id
    add_index :messages, :from_email
    add_index :messages, :to_email
  end
end
