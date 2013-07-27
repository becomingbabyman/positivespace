class RemoveAchievementsListFromUsers < ActiveRecord::Migration
  def change
    say_with_time "Track all achievements in achievements_list" do
      User.find_in_batches do |group|
        sleep(10) # Make sure it doesn't get too crowded in there!
        group.each do |u|
          if u.achievements_list.is_a? Array
            u.achievements_list.each do |n|
              u.track_achievement n
            end
          end
        end
      end
    end

    remove_column :users, :achievements_list
  end
end
