class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :user_id
      t.integer :attachable_id
      t.string :attachable_type
      t.string :image
      t.string :image_type
      t.string :name
      t.float :lat
      t.float :lng

      t.timestamps
    end
    add_index :images, :user_id
    add_index :images, :attachable_id
    add_index :images, :attachable_type
    add_index :images, [:attachable_id, :attachable_type]
  end
end
