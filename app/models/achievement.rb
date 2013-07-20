class Achievement < ActiveRecord::Base
	attr_accessible :none
	attr_protected :none, as: :admin

	has_paper_trail
	has_many :wins
	has_many :users, through: :wins

	validates :name, presence: true, :uniqueness => {:case_sensitive => false}, :length => 3..80
end
