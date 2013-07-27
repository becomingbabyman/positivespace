class AssignTaggerToAllTaggings < ActiveRecord::Migration
  def change
	say_with_time "Assign the taggable as the tagger for skills and interests" do
      ActsAsTaggableOn::Tagging.find_in_batches do |group|
        sleep(10) # Make sure it doesn't get too crowded in there!
        group.each do |t|
          t.update_attribute :tagger, t.taggable if t.tagger.nil?
        end
      end
    end
  end
end
