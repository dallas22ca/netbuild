class Medium < ActiveRecord::Base
  acts_as_taggable_on :tags
  
  belongs_to :website
  belongs_to :user
  
  default_scope -> { order("media.created_at desc") }
  
  before_save :prepare_info, if: :path_changed?
  before_save :set_meta_tags
  after_save :sidekiq_resize, if: Proc.new { is_format("Images") }
  
  def set_meta_tags
    if is_format("Images")
      self.tag_list.add("Images")
    elsif is_format("Audio")
      self.tag_list.add("Audio")
    elsif is_format("Video")
      self.tag_list.add("Video")
    end
  end
  
  def is_format(format)
    if format == "Images"
      self.extension =~ /\.(gif|png|jpeg|jpg)/
    elsif format == "Audio"
      self.extension =~ /\.(wav|mp3|ogg|wma)/
    elsif format == "Video"
      self.extension =~ /\.(mp4|avi|mov|wmv|)/
    else
      false
    end
  end
  
  def sidekiq_resize
    Resizer.perform_async id
  end
  
  def prepare_info
    self.path = CGI.unescape self.path.split(CONFIG["s3_bucket"]).last
    self.filename = File.basename path
    self.extension = File.extname path
  end
  
  def amazon_url(style = "original", format = false)
    if !resized?
      "http://#{CONFIG["s3_bucket"]}#{path}"
    elsif is_format("Images")
      amazon_path = path.gsub(/\/original\//, "/#{style}/")
      amazon_path = amazon_path.gsub(filename, CGI.escape(filename))
      amazon_path = amazon_path.sub(extension, ".#{format}") if format
      "http://#{CONFIG["s3_bucket"]}#{amazon_path}"
    elsif is_format("Video")
      if style == "original"
        "http://#{CONFIG["s3_bucket"]}#{amazon_path}"
      else
        amazon_path = path.gsub(/\/original\//, "/thumb/")
        amazon_path = amazon_path.gsub(filename, CGI.escape(filename))
        amazon_path = amazon_path.sub(extension, ".jpg")
        "http://#{CONFIG["s3_bucket"]}#{amazon_path}"
      end
    else
      "http://#{CONFIG["s3_bucket"]}#{path}"
    end
  end
  
  def resize
    require 'RMagick'
    
    if is_format("Images")
      variations = [
        { fill: true, width: 150, height: 150, style: "thumb", format: "jpg" }, 
        { width: 300, height: 300, style: "small" },
        { width: 600, height: 600, style: "medium" },
        { width: 1200, height: 1200, style: "large" },
      ]
    elsif is_format("Video")
      variations = [
        { width: 150, height: 150, style: "thumb", format: "jpg" }
      ]
    end
    
    FileUtils.mkdir_p "tmp/resizer"
    s3 = AWS::S3.new(access_key_id: CONFIG["s3_id"], secret_access_key: CONFIG["s3_secret"])
    bucket = s3.buckets[CONFIG["s3_bucket"]]
    
    if is_format("Images")
      i = Magick::ImageList.new
      image = i.from_blob(open(URI.encode(amazon_url)).read)
    end
    
    variations.each do |v|
      local_path = "tmp/resizer/#{Time.now.to_i}-#{SecureRandom.hex}-#{id}-#{v[:format]}"
      bucket_path = path[1..-1].gsub(/\/original\//, "/#{v[:style]}/")
      bucket_path = bucket_path.sub(extension, ".#{v[:format]}") unless v[:format].blank?
      obj = bucket.objects[bucket_path]
      
      if is_format("Images")
        if v[:fill]
          resized = image.resize_to_fill(v[:width], v[:height])
        else
          resized = image.resize_to_fit(v[:width], v[:height])
        end
      
        resized.write(local_path) {
          self.format = v[:format].upcase unless v[:format].blank?
          self.quality = 65 if v[:style] == "thumb"
        }
      elsif is_format("Video")
        if `wget -P #{local_path} #{amazon_url}`
          old_local_path = "#{local_path}/#{filename}"
          local_path = old_local_path.sub(extension, ".#{v[:format]}")
          movie = FFMPEG::Movie.new(old_local_path)
          movie.screenshot local_path, resolution: "#{v[:width]}x#{v[:height]}", preserve_aspect_ratio: :height
          File.delete old_local_path
        end
      end
      
      obj.write open(local_path).read, acl: :public_read
      File.delete(local_path)
    end
    
    image.destroy! if is_format("Images")
    update_columns resized: true
  end
end
