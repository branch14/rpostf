# Rpostf::Params.new(params).to_digest(passwd)
class Rpostf
  class Params

    attr_reader :data

    def initialize(data)
      data = data.to_a if data.is_a?(Hash)
      data = data.chunk if data.is_a?(Array) && data == data.flatten
      @data = data.to_a
    end

    def to_digest(passwd)
      to_hash(passwd).sha1
    end

    def to_hash(passwd)
      non_blank.upcased.sorted.concatinated(passwd)
    end

    def upcased
      Params.new(@data.map { |k, v| [k.to_s.upcase, v] })
    end

    def non_blank 
      Params.new(@data.reject { |k, v| v.nil? || (v.is_a?(String) && v.blank?) })
    end

    def sorted
      Params.new(@data.sort_by { |k, v| k.to_s })
    end

    def concatinated(passwd)
      @data.map { |a| ( a * '=' ) + passwd } * ''
    end

    def to_s
      @data.map { |d| d * '=' } * "\n"
    end

    def debug(passwd)
      [ "=== non blank params", non_blank.to_s,
        "=== upcased params", non_blank.upcased.to_s,
        "=== sorted params", non_blank.upcased.sorted.to_s,
        "=== hash", to_hash(passwd),
        "=== sha1 digest", to_digest(passwd) ] * "\n\n"
    end
  end
end
