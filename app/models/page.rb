class Page < ActiveRecord::Base
  liquid_methods :title, :path, :id
  
  belongs_to :website, touch: true
  belongs_to :layout, class_name: "Document", foreign_key: "document_id"
  
  belongs_to :parent, class_name: "Page", foreign_key: "parent_id"
  has_many :children, class_name: "Page", foreign_key: "parent_id"
  has_many :wrappers
  
  before_validation :set_defaults
  before_validation :permalink_is_not_safe, if: Proc.new { |p| %w[manage auth sign_out].include? p.permalink }
  validates_uniqueness_of :permalink, scope: [:website_id, :parent_id], case_sensitive: false
  validates_presence_of :document_id
  validates_presence_of :published_at
  validates_presence_of :title, allow_blank: false
  validate :cannot_have_dates_if_parent_has_dates, if: Proc.new { |p| !p.root? && p.parent.children_have_dates? && p.children_have_dates? }
  
  default_scope -> { order :ordinal }
  
  scope :roots, -> { where parent_id: nil }
  scope :not_dated, -> { where children_have_dates: false }
  scope :dated, -> { where children_have_dates: true }
  scope :roots_or_dated, -> { where "pages.parent_id is ? or children_have_dates = ?", nil, true }
  scope :visible, -> { where visible: true }
  
  def set_defaults
    self.published_at = Time.zone.now if self.published_at.blank?
  end
  
  def permalink_is_not_safe
    self.errors.add :permalink, "is a reserved word and cannot be used."
  end
  
  def cannot_have_dates_if_parent_has_dates
    self.errors.add :parent, "page is unavailable as a parent as it is a grouped section in and of itself."
  end
  
  def has_siblings?
    !siblings.empty?
  end
  
  def siblings
    website.pages.where(parent_id: parent_id)
  end
  
  def root?
    parent_id == nil
  end
  
  def body_with_partials
    @body_with_partials ||= layout.body.to_s
    
    while @body_with_partials =~ /\{\{(.*?)render(.*?)\}\}/
      website.theme.documents.partials.each do |d|
        @body_with_partials = @body_with_partials.gsub(/\{\{\s*render\s*"#{d.name}"\s*\}\}/, d.body.html_safe.gsub(/\{\{\s*render\s*"#{d.name}"\s*\}\}/, ""))
      end
    end
    
    @body_with_partials.html_safe
  end
  
  def path(params = {})
    imploded_params = "#{"?" unless params.empty?}#{params.map{|k, v| "#{k}=#{v}" }.join("&")}"
    
    @path ||= if website.home_id == id
  		"/#{imploded_params}"
    elsif website.home_id == parent_id
      if parent.children_have_dates?
        "/#{published_at.year}/#{published_at.month}/#{permalink}#{imploded_params}"
      else
        "/#{permalink}#{imploded_params}"
      end
    elsif children_have_dates?
      "/#{permalink}#{imploded_params}"
    elsif !root?
      if parent.children_have_dates?
        "/#{parent.permalink}/#{published_at.year}/#{published_at.month}/#{permalink}#{imploded_params}"
      elsif parent.root?
    		"/#{parent.permalink}/#{permalink}#{imploded_params}"
      else
        "/#{grandparent.permalink}/#{parent.permalink}/#{permalink}#{imploded_params}"
      end
  	else
  		"/#{permalink}#{imploded_params}"
  	end
  end
  
  def grandparent
    parent.parent
  end
  
  def has_children?
    !children.empty?
  end
end
