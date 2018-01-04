#!/usr/bin/env ruby
require '../lib/chemical_equation_balancer'

puts "Enter a chemical equation in the form of CH3COOH+NaHCO3=CH3COONa+H2O+CO2.\nPress Ctrl+C to exit program."
while true
  print '<<'
  val = gets
  begin
    tokens = Tokenizer.new.tokenize(val.chop)
    parser = Parser.new(tokens).parse
    mat =ParserResultToMatrixHelper.new(parser.left,parser.right).to_matrix
    solver = LinearSolver.new(mat)
    print '>>'
    p solver.solve
  rescue => exception
    puts "ERROR: "+exception.to_s
  end
end
