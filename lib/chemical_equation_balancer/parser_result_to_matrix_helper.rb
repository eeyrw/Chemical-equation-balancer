class ParserResultToMatrixHelper
  def initialize left, right
    @left=left
    @right=right
  end

  def to_matrix
    elem_hash = @left.inject(:+).map(&:first).uniq.map.with_index.to_h

    molecules = @left + @right.map{|molecule| molecule.map{|elem, num| [elem, -num]}}
    mat = elem_hash.map{ [0] * molecules.size }

    molecules.each_with_index do |molecule, index|
      molecule.each do |element|
        mat[elem_hash[element[0]]][index] += element[1]
      end
    end

    mat
  end
end
