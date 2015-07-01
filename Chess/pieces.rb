require_relative "board"

module Movable
  DIRECTION = { :vertical => [0, 1],
                :horizontal => [1 , 0],
                :pos_diag => [1, -1],
                :neg_diag => [1, 1] }

  def get_moves(direction)
    dx, dy = DIRECTION[direction]
    positions(dx, dy, true) + positions(dx, dy, false)
  end

  def positions(dr, dc, positive)
    avail_pos = []
    direction = (positive ? 1 : -1)
    next_pos = [pos[0] + (dr * direction), pos[1] + (dc * direction)]
    while Board.on_board?(next_pos) && board[*next_pos].empty?
      avail_pos << next_pos
      next_pos = [next_pos[0] + (dr * direction), next_pos[1] + (dc * direction)]
    end

    if Board.on_board?(next_pos) && @board[*next_pos].color == other_color
      avail_pos << next_pos
    end

    avail_pos
  end
end

module Diagonalizable
  include Movable

  def diagonal_moves
    pos_diagonal_moves + neg_diagonal_moves
  end

  #private
    def pos_diagonal_moves
      get_moves(:pos_diag)
    end

    def neg_diagonal_moves
      get_moves(:neg_diag)
    end
end

module Lateralizable
  include Movable

  def lateral_moves
    vertical_moves + horizontal_moves
  end

  #private
    def vertical_moves
      get_moves(:vertical)
    end

    def horizontal_moves
      get_moves(:horizontal)
    end
end

class Piece
  attr_reader :board, :pos, :color
  attr_accessor :moved

  def initialize(pos, board, color)
    @board = board
    @pos = pos
    @color = color
  end

  def empty?
    false
  end

  def king?
    false
  end

  def inspect
    "<Pos: #{pos}, Color: #{color}> \nCurrent piece: #{self.class}"
  end

  def move
    raise "Not yet implemented"
  end

  def other_color
    color == :white ? :black : :white
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

  def empty?
    true
  end

  def available_moves
    []
  end

  def color
    false
  end

  def to_s
    " "
  end
end

class SlidingPiece < Piece

  def move
  end

  def valid_moves
  end
end

class SteppingPiece < Piece
  def initialize(pos, board, color)
    super
    @deltas = nil
  end

  def available_moves
    moves = []
    @deltas.each do |delta|
      new_pos = [delta[0] + pos[0], delta[1] + pos[1]]
      moves << new_pos if Board.on_board?(new_pos) && board[*new_pos].color != color
    end
    moves
  end

  def move
  end

end

class Rook < SlidingPiece
  include Lateralizable

  def available_moves
    lateral_moves
  end

  def to_s
    color == :white ? "\u2656" : "\u265c"
  end
end

class Knight < SteppingPiece
  def initialize(pos, board, color)
    super
    @deltas = [[-1,-2], [1, -2], [-1, 2], [1, 2],
            [-2, -1], [-2, 1], [2, -1], [2, 1]]
  end

  def available_moves
    super
  end

  def to_s
    color == :white ? "\u2658" : "\u265e"
  end
end

class Bishop < SlidingPiece
  include Diagonalizable

  def available_moves
    diagonal_moves
  end

  def to_s
    color == :white ? "\u2657" : "\u265d"
  end
end

class King < SteppingPiece

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

class Queen < SlidingPiece
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
  def initialize(pos, board, color)
    super
    @moved = false
  end

  def available_moves
    []
  end

  def to_s
    color == :white ? "\u2659" : "\u265f"
  end

end
