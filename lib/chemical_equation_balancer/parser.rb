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
