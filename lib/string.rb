require 'digest/sha1'

class String
  def sha1
    Digest::SHA1.hexdigest(self).upcase
  end
end
