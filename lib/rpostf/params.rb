# Rpostf::Params.new(params).to_digest(passwd)
#
class Rpostf

  class Params

    def initialize(data)
      @data = data.to_a
    end

    def to_digest(passwd)
      to_hash(passwd).sha1
    end

    def to_hash(passwd)
      non_blank.upcase.sorted.concatinated(passwd)
    end

    def upcase
      Params.new(@data.map { |k, v| [k.to_s.upcase, v] })
    end

    def non_blank 
      Params.new(@data.reject { |k, v| v.blank? })
    end

    def sorted
      Params.new(@data.sort_by { |k, v| k.to_s })
    end

    def concatinated(passwd)
      @data.map { |a| ( a * '=' ) + passwd } * ''
    end

  end

end
