class CreateMagnetisms < ActiveRecord::Migration
  def change
    create_table :magnetisms do |t|
      t.integer :inc
      t.string :reason
      t.text :note
      t.integer :user_id
      t.integer :attachable_id
      t.string :attachable_type

      t.timestamps
    end
    add_index :magnetisms, :inc
    add_index :magnetisms, :reason
    add_index :magnetisms, :user_id
    add_index :magnetisms, :attachable_id
    add_index :magnetisms, :attachable_type

    add_column :users, :magnetisms_count, :integer, default: 0

    Magnetism.reset_column_information
    User.reset_column_information

    say_with_time "Make user magnetisms" do
      User.find_in_batches do |group|
        sleep(10) # Make sure it doesn't get too crowded in there!
        group.each do |u|
          u.magnetisms.create(inc: u.magnetism, reason: 'onboarding complete', attachable: u.conversations.first, callback: :none) if u.magnetism > 0
        end
      end
    end
  end
end
