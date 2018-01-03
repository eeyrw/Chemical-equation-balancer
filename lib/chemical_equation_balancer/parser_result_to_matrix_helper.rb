class ParserResultToMatrixHelper
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
