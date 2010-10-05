class Array

  def chunk(pieces=2)
    raise StandardError.new('unmatched number of elements to chunk') if (size % pieces) != 0
    klon = dup
    Array.new.tap do |a|
      until klon.empty?
        a << klon.slice!(0..(pieces-1))
      end
    end
  end

end
