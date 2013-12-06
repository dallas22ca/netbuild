class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  attr_accessor :subdomain, :no_password, :data

  has_many :memberships
  has_many :websites, through: :memberships
  has_many :media, through: :websites

  def self.find_for_authentication(conditions = {})
    website = Website.where(permalink: conditions.delete(:subdomain)).first
    user = User.where(conditions).first

    if user && website && user.memberships.where(website_id: website.id).any?
      user
    else
      false
    end
  end
  
  def super_admin?
    admin
  end
  
  def has_password?
    !encrypted_password.blank?
  end
  
  def password_required?
    if no_password == true
      false
    else
      super
    end
  end
  
  def name_and_email
    email
  end
end
