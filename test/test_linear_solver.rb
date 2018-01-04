require '../lib/chemical_equation_balancer'
require 'minitest/autorun'

class TestLinearSolver < Minitest::Test
  def test_linear_solver
    equation = 'Al2O3+H2SO4=Al2(SO4)3+H2O'
    tokens = Tokenizer.new.tokenize(equation)
    parser = Parser.new(tokens).parse

    mat = ParserResultToMatrixHelper.new(parser.left, parser.right).to_matrix
    solver = LinearSolver.new(mat)
    assert_equal [1, 3, 1, 3], solver.solve

    assert_raises LinearSolver::NoSolutionError do
      equation = 'Fe36Si5+H3PO3+K2Cr2O7+H2O=FePO4+Fe(OH)3+Cr(OH)3+CrPO4+K3PO4+SiO2'
      tokens = Tokenizer.new.tokenize(equation)
      parser = Parser.new(tokens).parse

      mat = ParserResultToMatrixHelper.new(parser.left, parser.right).to_matrix
      solver = LinearSolver.new(mat)
      solver.solve
    end

    equation = 'CuSO4+FeS2+H2O=Cu2S+FeSO4+H2SO4'
    tokens = Tokenizer.new.tokenize(equation)
    parser = Parser.new(tokens).parse

    mat = ParserResultToMatrixHelper.new(parser.left, parser.right).to_matrix
    solver = LinearSolver.new(mat)
    assert_equal [14, 5, 12, 7, 5, 12], solver.solve
  end

  def test_reduced_row_echelon_form
    equation = 'Al2O3+H2SO4=Al2(SO4)3+H2O'
    tokens = Tokenizer.new.tokenize(equation)
    parser = Parser.new(tokens).parse

    mat = ParserResultToMatrixHelper.new(parser.left, parser.right).to_matrix
    solver = LinearSolver.new(mat)

    expected = eval %[[[(1/1), (0/1), (0/1), (-1/3)], [(0/1), (1/1), (0/1), (-1/1)], [(0/1), (0/1), (1/1), (-1/3)], [(0/1), (0/1), (0/1), (0/1)]]].gsub(/\((.+?)\/(.+?)\)/, 'Rational(\1, \2)')
    assert_equal expected, solver.reduced_row_echelon_form(mat)
  end
end
