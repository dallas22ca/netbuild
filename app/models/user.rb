class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
 attr_accessor :subdomain
         
  before_save :make_admin, if: Proc.new { |u| u.email == "dallas@livehours.co" }
  
  has_many :memberships
  has_many :websites, through: :memberships
  has_many :media, through: :websites
  
  def make_admin
    self.admin = true
  end
  
  def self.find_for_authentication(conditions = {})
    website = Website.where(permalink: conditions.delete(:subdomain)).first
    user = User.where(conditions).first
    if user && website && user.memberships.where(website_id: website.id).any?
      user
    else
      false
    end
  end
end
