class Administrator < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  # :registerable, :recoverable, :rememberable
  devise :database_authenticatable, :trackable, :validatable

  attr_accessor :login
  attr_accessible :email, :password, :login
  attr_protected :none, as: :admin

  # Authenticate with email or username
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions).where(["lower(email) = :value", { :value => login.strip.downcase }]).first
  end

  def admin?
    true
  end
end
