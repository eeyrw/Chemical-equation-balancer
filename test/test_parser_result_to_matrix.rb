require '../lib/chemical_equation_balancer'
require 'minitest/autorun'

class TestParserResultToMatrix < Minitest::Test
  def test_parser_equation
    equation = 'Al2O3+H2SO4=Al2(SO4)3+H2O'
    tokens = Tokenizer.new.tokenize(equation)
    parser = Parser.new(tokens).parse

    mat = ParserResultToMatrixHelper.new(parser.left, parser.right).to_matrix
    assert_equal [[2, 0, -2, 0], [3, 4, -12, -1], [0, 2, 0, -2], [0, 1, -3, 0]], mat.to_a

    equation = 'Fe36Si5+H3PO3+K2Cr2O7+H2O=FePO4+Fe(OH)3+Cr(OH)3+CrPO4+K3PO4+SiO2'
    tokens = Tokenizer.new.tokenize(equation)
    parser = Parser.new(tokens).parse

    mat = ParserResultToMatrixHelper.new(parser.left, parser.right).to_matrix
    assert_equal [[36, 0, 0, 0, -1, -1, 0, 0, 0, 0], [5, 0, 0, 0, 0, 0, 0, 0, 0, -1], [0, 3, 0, 2, 0, -3, -3, 0, 0, 0], [0, 1, 0, 0, -1, 0, 0, -1, -1, 0], [0, 3, 7, 1, -4, -3, -3, -4, -4, -2], [0, 0, 2, 0, 0, 0, 0, 0, -3, 0], [0, 0, 2, 0, 0, 0, -1, -1, 0, 0]], mat.to_a
  end
end
