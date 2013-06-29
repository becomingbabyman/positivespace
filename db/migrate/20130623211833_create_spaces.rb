class CreateSpaces < ActiveRecord::Migration
  def change
    create_table :spaces do |t|
      t.integer :user_id
      t.text :prompt
      t.text :state
      t.text :embed_url
      t.text :embed_data

      t.timestamps
    end

    add_column :users, :bio, :text

    add_index :spaces, :user_id
    add_index :spaces, :prompt
    add_index :spaces, :state
    add_index :spaces, :embed_url

    Space.reset_column_information

    say_with_time "Put users bodies into spaces" do
      User.find_in_batches do |group|
        sleep(50) # Make sure it doesn't get too crowded in there!
        group.each do |u|
          u.spaces.create(prompt: u.body, state_event: :publish)
        end
      end
    end
  end
end
