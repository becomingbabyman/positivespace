class CreateMagnetismsAndAchievements < ActiveRecord::Migration
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


    create_table :achievements do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
    add_index :achievements, :name

    rename_column :users, :achievements, :achievements_list
    change_column_default :users, :achievements_list, []
    add_column :users, :achievements_count, :integer, default: 0


    create_table :wins do |t|
      t.integer :achievement_id
      t.integer :user_id

      t.timestamps
    end
    add_index :wins, :achievement_id
    add_index :wins, :user_id
    add_index :wins, [:achievement_id, :user_id]


    Win.reset_column_information
    Achievement.reset_column_information
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

    say_with_time "Make achievements_list an array" do
      User.find_in_batches do |group|
        sleep(10) # Make sure it doesn't get too crowded in there!
        group.each do |u|
          u.achievements_list = u.achievements_list.map{|k,v| k.to_s}
          u.save
        end
      end
    end

    say_with_time "Make achievements" do
      User.find_in_batches do |group|
        sleep(10) # Make sure it doesn't get too crowded in there!
        group.each do |u|
          u.achievements_list.each do |name|
            u.track_achievement name
          end
        end
      end
    end

  end
end
