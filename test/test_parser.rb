require '../lib/chemical_equation_balancer'
require 'minitest/autorun'

class TestParser < Minitest::Test
  def test_parser_equation
    equation = 'Al2O3+H2SO4=Al2(SO4)3+H2O'
    tokens = Tokenizer.new.tokenize(equation)
    parser = Parser.new(tokens).parse

    expected_left = [
      {
        Al: 2,
        O: 3
      },
      {
        H: 2,
        S: 1,
        O: 4
      }
    ]
    expected_right = [
      {
        Al: 2,
        S: 3,
        O: 12
      },
      {
        H: 2,
        O: 1
      }
    ]
    assert_equal expected_left, parser.left.map{|molecule| molecule.map{|x| [x[0].to_sym, x[1]]}.to_h}
    assert_equal expected_right, parser.right.map{|molecule| molecule.map{|x| [x[0].to_sym, x[1]]}.to_h}
  end
end
