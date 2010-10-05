class Hash

  def reverse_merge(other_hash)
    other_hash.merge(self)
  end

  def symbolize_keys!
    self.each do |key, value|
      if key.is_a?(String)
        self[key.to_sym] = self.delete(key)
      end
    end
  end

end
