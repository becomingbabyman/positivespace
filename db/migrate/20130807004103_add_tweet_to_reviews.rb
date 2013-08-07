class AddTweetToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :tweet, :text
  end
end
