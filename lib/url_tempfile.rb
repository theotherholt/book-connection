require 'openssl'
require 'open-uri'

class URLTempfile < Tempfile
  def initialize(url)
    @url = URI.parse(url)
    
    unless self.original_filename
      raise 'Unable to determine filename for URL uploaded file.'
    end
    
    super('urlupload')
    
    Kernel.open(url) do |file|
      @content_type = file.content_type
      
      unless @content_type
        raise 'Unable to determine MIME type for URL uploaded file.'
      end
      
      self.write(file.read)
      self.flush
    end
  end
  
  def content_type
    @content_type
  end
  
  def original_filename
    if match = @url.path.match(/^.*\/(.+)$/)
      match[1]
    else
      nil
    end
  end
end