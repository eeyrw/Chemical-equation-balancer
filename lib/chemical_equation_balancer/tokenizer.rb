require 'strscan'

class Tokenizer
  def tokenize(str)
    ss = StringScanner.new(str)
    tokens = []

    until ss.empty?
      case
      when ss.scan(/[A-Z][a-z]*/)
        tokens << [:elem, ss.matched]
      when ss.scan(/\d+/)
        tokens << [:num, ss.matched]
      when ss.scan(/\(|\)|=|\+/)
        tokens << [ss.matched]
      else
        p ss
        raise "unknown token"
      end
    end
    tokens
  end
end
