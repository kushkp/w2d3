require 'byebug'
require_relative "pieces"

class Board
  attr_accessor :move_made, :current_color

  def initialize(populate = true)
    @grid = Array.new(8) { Array.new(8) { EmptySquare.new } }
    populate_grid if populate
    @move_made = false
    @current_color = :black
  end

  def dup
    new_board = Board.new(false)
    (0..7).each do |i|
      (0..7).each do |j|
        if self[i, j].is_a?(Piece)
          curr_piece = self[i, j]
          new_board[i, j] = curr_piece.dup([i, j], new_board, curr_piece.color)
          new_board[i, j].has_moved if curr_piece.moved
        end
      end
    end

    new_board
  end

  def on_board?(pos)
    pos.all? { |coord| coord.between?(0,7) }
  end

  def checkmate?(color)
    in_check?(color) && !any_valid_moves?(color)
  end

  def any_valid_moves?(color)
    all_pieces(color).any? do |piece|
      piece.available_moves.any? do |move|
        valid_move?(piece.pos, move)
      end
    end
  end

  def size
    grid.size
  end

  def [](row, col)
    @grid[row][col]
  end

  def []=(row, col, value)
    @grid[row][col] = value
  end

  def empty_on_board?(pos)
    on_board?(pos) && self[*pos].empty?
  end

  def find_king(color)
    grid.flatten.each do |square|
      if square.is_a?(King) && square.color == color
        return square
      end
    end

    nil
  end

  def populate_grid
    add_pawns
    add_rooks
    add_bishops
    add_knights
    add_queens_and_kings
  end

  def in_check?(color)
    king = find_king(color)
    opposing_color = king.other_color
    opposing_pieces = all_pieces(opposing_color)

    opposing_pieces.any? do |piece|
      piece.available_moves.include?(king.pos)
    end
  end

  def all_pieces(color)
    pieces = []
    (0..7).each do |i|
      (0..7).each do |j|
        if self[i, j].color == color
          pieces << self[i, j]
        end
      end
    end

    pieces
  end

  def move(start_pos, end_pos)
    return if start_pos == end_pos
    if valid_move?(start_pos, end_pos)
      self[*end_pos] = self[*start_pos]
      self[*end_pos].pos = end_pos
      self[*start_pos] = EmptySquare.new
      self[*end_pos].has_moved if self[*end_pos].is_a?(Pawn)
      self.move_made = true
      switch_colors
    else
      self.move_made = false
    end
  end

  def move!(start_pos, end_pos)
    return if start_pos == end_pos
    self[*end_pos] = self[*start_pos]
    self[*end_pos].pos = end_pos
    self[*start_pos] = EmptySquare.new
    self[*end_pos].has_moved if self[*end_pos].is_a?(Pawn)
  end

  def valid_move?(start_pos, end_pos)
    return false if self[*start_pos].color != current_color
    current_piece = self[*start_pos]
    valid_moves = current_piece.available_moves.reject do |move|
      current_piece.move_into_check?(move)
    end
    valid_moves.include?(end_pos)
  end

  def switch_colors
    self.current_color = (current_color == :black ? :white : :black )
  end

  private
    attr_reader :grid

    def add_pawns
      size.times do |col|
        self[1, col] = Pawn.new([1, col], self, :black)
        self[6, col] = Pawn.new([6, col], self, :white)
      end
    end

    def add_rooks
      self[0, 0] = Rook.new([0, 0], self, :black)
      self[0, 7] = Rook.new([0, 7], self, :black)
      self[7, 0] = Rook.new([7, 0], self, :white)
      self[7, 7] = Rook.new([7, 7], self, :white)
    end

    def add_knights
      self[0, 1] = Knight.new([0, 1], self, :black)
      self[0, 6] = Knight.new([0, 6], self, :black)
      self[7, 1] = Knight.new([7, 1], self, :white)
      self[7, 6] = Knight.new([7, 6], self, :white)
    end

    def add_bishops
      self[0, 2] = Bishop.new([0, 2], self, :black)
      self[0, 5] = Bishop.new([0, 5], self, :black)
      self[7, 2] = Bishop.new([7, 2], self, :white)
      self[7, 5] = Bishop.new([7, 5], self, :white)
    end

    def add_queens_and_kings
      self[0, 3] = Queen.new([0, 3], self, :black)
      self[0, 4] = King.new([0, 4], self, :black)
      self[7, 3] = Queen.new([7, 3], self, :white)
      self[7, 4] = King.new([7, 4], self, :white)
    end
end
