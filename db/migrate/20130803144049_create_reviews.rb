class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer :reviewable_id, null: false
      t.string :reviewable_type, null: false
      t.integer :rating
      t.boolean :vote
      t.integer :user_id, null: false
      t.text :explanation

      t.timestamps
    end

    add_column :users, :reviewed_count, :integer, default: 0, null: false
    add_column :conversations, :reviews_count, :integer, default: 0, null: false

    add_index :reviews, :reviewable_id
    add_index :reviews, :reviewable_type
    add_index :reviews, [:reviewable_id, :reviewable_type]
    add_index :reviews, :rating
    add_index :reviews, :vote
    add_index :reviews, :user_id

    add_index :users, :reviewed_count
    add_index :conversations, :reviews_count
  end
end
