#!/usr/bin/env ruby
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

class Parser
  attr_reader :left, :right

  def initialize tokens
    @tokens = tokens
    @current = 0
  end

  def parse
    @left = read_side
    if current_token == ['=']
      @current += 1
    else
      raise 'expecting ='
    end
    @right = read_side
    self
  end

  def read_molecule
    elements = []
    element_group = []
    reading_group = false
    while true
      if current_token[0] == :elem
        if next_token[0] == :num
          matched = [current_token[1], next_token[1].to_i]
          if reading_group
            element_group << matched
          else
            elements << matched
          end
          @current += 2
        else
          matched = [current_token[1], 1]
          if reading_group
            element_group << matched
          else
            elements << matched
          end
          @current += 1
        end
      elsif current_token == ['(']
        reading_group = true
        @current += 1
      elsif current_token == [')']
        reading_group = false
        if next_token[0] == :num
          elements.concat element_group.map{|elem, num| [elem, num * next_token[1].to_i]}
          @current += 2
        else
          elements.concat element_group
          @current += 1
        end
      else
        break
      end
    end
    elements.empty? ? nil : elements
  end

  def read_side
    molecules = []
    while true
      if molecule = read_molecule
        molecules << molecule
        if current_token == ['+']
          @current += 1
        end
      else
        break
      end
    end
    molecules
  end

  def current_token
    @tokens[@current] || []
  end

  def next_token
    @tokens[@current + 1] || []
  end
end

class Linear_solver
    def initialize mat
        @mat = mat
    end

    # returns an 2-D array where each element is a Rational
    def reduced_row_echelon_form(ary)
      lead = 0
      rows = ary.size
      cols = ary[0].size
      rary = convert_to(ary, :to_r)  # use rational arithmetic
      catch :done  do
        rows.times do |r|
          throw :done  if cols <= lead
          i = r
          while rary[i][lead] == 0
            i += 1
            if rows == i
              i = r
              lead += 1
              throw :done  if cols == lead
            end
          end
          # swap rows i and r 
          rary[i], rary[r] = rary[r], rary[i]
          # normalize row r
          v = rary[r][lead]
          rary[r].collect! {|x| x / v}
          # reduce other rows
          rows.times do |i|
            next if i == r
            v = rary[i][lead]
            rary[i].each_index {|j| rary[i][j] -= v * rary[r][j]}
          end
          lead += 1
        end
      end
      rary
    end
    
    # type should be one of :to_s, :to_i, :to_f, :to_r
    def convert_to(ary, type)
      ary.each_with_object([]) do |row, new|
        new << row.collect {|elem| elem.send(type)}
      end
    end
    
    class Rational
      alias _to_s to_s
      def to_s
        denominator==1 ? numerator.to_s : _to_s
      end
    end
    
    def print_matrix(m)
      max = m[0].collect {-1}
      m.each {|row| row.each_index {|i| max[i] = [max[i], row[i].to_s.length].max}}
      m.each {|row| row.each_index {|i| print "%#{max[i]}s " % row[i]}; puts}
    end

    def solve
        result_mat=reduced_row_echelon_form(@mat)
        cols=@mat[0].size
        rows=@mat.size
        rank=0
        for i in 0..[cols-1,rows-1].min
          if result_mat[i][i]!=0 then
            rank+=1
          end
        end

        #齐次线性方程组在满秩的情况下只有0解，对于本应用没有意义，认为是无解
        #此外对于方程式配平而言只存在自由变量是一个的情况
        if rank!=(cols-1) then
          raise 'No solution.'
        end

        free_var_count=cols-rank
        free_vars=Array.new
        specific_vars=Array.new

        for i in 0..(free_var_count-1)
          free_vars<<1 #自由变量取1
        end

        for i in 0..(rank-1)
          solution=0
          for j in rank..(cols-1)
            solution-=result_mat[i][j]
          end
          specific_vars<<solution
        end

        total_solution=specific_vars+free_vars
      
        arr=Array.new
        for i in 0..(cols-1)
          arr<<total_solution[i].denominator
        end
        lcm=arr.reduce(1, :lcm)
        for i in 0..(cols-1)
          total_solution[i]*=lcm
          total_solution[i]=total_solution[i].to_i
        end
        total_solution
    end

end

class Parser_result_to_matrix_helper
    def initialize left,right
      @left=left
      @right=right
    end
   
    def to_matrix
      elem_hash=Hash.new
      elem_index=0;
      
      @left.each do |i|
        i.each do |j|
          if elem_hash[j[0]]==nil then
            elem_hash[j[0]]=elem_index
            elem_index+=1
          end
        end
      end
      
      elem_count=elem_hash.size
      molecule_count=@left.size+@right.size
      
      mat=Array.new(elem_count)
      
      for i in 0..elem_count-1
        mat[i]=Array.new(molecule_count,0)
      end
      
      molecule_index=0
      
      @left.each do |i|
        i.each do |j|
          mat[elem_hash[j[0]]][molecule_index]+=j[1]
          end
          molecule_index+=1
      end
      
      @right.each do |i|
        i.each do |j|
          mat[elem_hash[j[0]]][molecule_index]-=j[1]
          end
          molecule_index+=1
      end
      mat
    end
end


puts "Enter a chemical equation in the form of CH3COOH+NaHCO3=CH3COONa+H2O+CO2.\nPress Ctrl+C to exit program."
while true
  print '<<'
  val = gets
  begin
    tokens = Tokenizer.new.tokenize(val.chop)
    parser = Parser.new(tokens).parse
    mat =Parser_result_to_matrix_helper.new(parser.left,parser.right).to_matrix
    solver = Linear_solver.new(mat)
    print '>>'
    p solver.solve  
  rescue => exception
    puts "ERROR: "+exception.to_s
  end
end