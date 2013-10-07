class Medium < ActiveRecord::Base
  belongs_to :website
  belongs_to :user
  
  before_save :prepare_info
  
  def prepare_info
    self.path = CGI.unescape self.path.split(CONFIG["s3_bucket"]).last
    self.name = self.filename.split(".").first
    self.extension = self.filename.split(".").last.downcase
  end
  
  def filename
    self.path.split("/").last
  end
  
  def amazon_url
    "http://s3.amazonaws.com/#{CONFIG["s3_bucket"]}#{path}"
  end
end
