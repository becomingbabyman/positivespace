class AddGenderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gender, :string
    add_column :users, :birthday, :datetime
    add_column :users, :locale, :string
    add_column :users, :timezone, :integer
  end
end
