require 'digest/sha1'

class String

  def sha1
    Digest::SHA1.hexdigest(self)
  end

  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

end
