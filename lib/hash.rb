class Hash
  def reverse_merge!(other_hash)
    replace(other_hash.merge!(self))
  end
end
