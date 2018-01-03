class LinearSolver
  NoSolutionError = Class.new(RuntimeError)

  def initialize mat
    @mat = mat
  end

  # returns an 2-D array where each element is a Rational
  def reduced_row_echelon_form(ary)
    lead = 0
    rows = ary.size
    cols = ary[0].size
    rary = ary.map{|row| row.map(&:to_r)}

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

  def reduced_row_echelon_form1(ary)
    rary = ary.map{|row| row.map(&:to_r)}

    rary.size.times do |processing|
      (processing...rary.size).each do |index|
        rary[index] = normalize_line(rary[index], processing)
      end
      p [processing, rary]
      if rary[processing][processing] == 0
        non_zero = rary[processing..-1].find{|x| x[processing] != 0}
        rary[processing] = subtract_line(non_zero, rary[processing]) if non_zero
      end

      (processing+1...rary.size).each do |index|
        rary[index] = subtract_line(rary[index], rary[processing]) if rary[index][processing] != 0
      end
      p rary
    end
    rary

  end

  def normalize_line line, index
    return line if line[index] == 0
    line.map{|x| x / line[index]}
  end

  def subtract_line line1, line2
    line1.zip(line2).map{|a, b| a - b}
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
    result_mat = reduced_row_echelon_form(@mat)
    cols = @mat[0].size
    rows = @mat.size
    rank = 0
    for i in 0..[cols-1,rows-1].min
      if result_mat[i][i]!=0 then
        rank+=1
      end
    end

    #齐次线性方程组在满秩的情况下只有0解，对于本应用没有意义，认为是无解
    #此外对于方程式配平而言只存在自由变量是一个的情况
    if rank!=(cols-1) then
      raise NoSolutionError, 'No solution.'
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

#mat = [[0, 0, -2, 0], [3, 4, -12, -1], [0, 2, 0, -2], [0, 1, -3, 0]]
mat = [[2, 3, 5, 6],
[4, 1, 4, 5],
[1, 2, 3, 4],
[3, 6, 7, 9]]
solver = LinearSolver.new(mat)
p solver.reduced_row_echelon_form1(mat)
