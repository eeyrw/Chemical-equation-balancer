class LinearSolver
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
