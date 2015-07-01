require_relative 'modules'

class Piece
  include Movable

  attr_reader :board, :color
  attr_accessor :moved, :pos


  def initialize(pos, board, color)
    @board = board
    @pos = pos
    @color = color
    @moved = false
  end

  def empty?
    false
  end

  def king?
    false
  end

  def inspect
    "<Pos: #{pos}, Color: #{color}> \nClass: #{self.class}"
  end

  def move
    raise "Not yet implemented"
  end

  def dup(pos, board, color)
    self.class.new(pos, board, color)
  end

  def move_into_check?(pos)
    start_pos = self.pos
    end_pos = pos
    new_board = board.dup
    new_board.move!(start_pos, end_pos)
    new_board.in_check?(color)
  end


  def opponent_at?(pos)
    board.on_board?(pos) && board[*pos].color == other_color
  end

  def other_color
    color == :white ? :black : :white
  end

  def reject_in_check_moves
    current_piece.available_moves.reject do |move|
      current_piece.move_into_check?(move)
    end
  end

  def to_s
    raise "Not working"
  end

  def valid_moves
    raise "Not yet implemented"
  end

end

class EmptySquare
  def initialize
  end

  def color
    false
  end

  def empty?
    true
  end

  def available_moves
    []
  end

  def to_s
    " "
  end
end



class Rook < Piece
  include Lateralizable

  def available_moves
    lateral_moves
  end

  def to_s
    color == :white ? "\u2656" : "\u265c"
  end
end

class Knight < Piece
  include SteppingPiece

  def initialize(pos, board, color)
    super
    @deltas = [[-1,-2], [1, -2], [-1, 2], [1, 2],
            [-2, -1], [-2, 1], [2, -1], [2, 1]]
  end

  def to_s
    color == :white ? "\u2658" : "\u265e"
  end
end

class Bishop < Piece
  include Diagonalizable

  def available_moves
    diagonal_moves
  end

  def to_s
    color == :white ? "\u2657" : "\u265d"
  end
end

class King < Piece
  include SteppingPiece

  def initialize(pos, board, color)
    super
    @deltas = [-1,0,1].repeated_permutation(2).to_a.reject {|d| d == [0,0] }
  end

  def available_moves
    super
  end

  def to_s
    color == :white ? "\u2654" : "\u265a"
  end

  def king?
    true
  end
end

class Queen < Piece
  include Diagonalizable
  include Lateralizable

  def available_moves
    lateral_moves + diagonal_moves
  end

  def to_s
    color == :white ? "\u2655" : "\u265b"
  end
end

class Pawn < Piece
  DIRECTION = { :black => [1,0], :white => [-1,0] }

  def initialize(pos, board, color)
    super
  end

  def vertical_moves
    vertical_moves = []
    num_spaces = 1 + (@moved ? 0 : 1)
    new_pos = pos
    num_spaces.times do
      new_pos = add_change_to_pos(DIRECTION[color], new_pos)
      vertical_moves << new_pos
    end

    vertical_moves
  end

  def add_change_to_pos(differential, pos)
    [pos[0] + differential[0], pos[1] + differential[1]]
  end

  def capture_moves
    direction = DIRECTION[color]
    left_capture = add_change_to_pos([direction[0], -1], pos)
    right_capture = add_change_to_pos([direction[0], 1], pos)
    [left_capture, right_capture].select do |position|
      opponent_at?(position)
    end
  end

  def has_moved
    @moved = true
  end

  def available_moves
    vertical_moves + capture_moves
  end

  def to_s
    color == :white ? "\u2659" : "\u265f"
  end
end
