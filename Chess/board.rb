require_relative "pieces"

class Board
  def initialize
    @grid = Array.new(8) { Array.new(8) { EmptySquare.new } }
    populate_grid
  end

  def self.on_board?(pos)
    pos.all? { |coord| coord.between?(0,7) }
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

  def find_king(color)
    (0..7).each do |i|
      (0..7).each do |j|
        if self[i, j].is_a?(King) && self[i, j].color == color
          return [i, j]
        end
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
    king_pos = find_king(color)
    opposing_color = self[*king_pos].other_color
    opposing_pieces = all_pieces(opposing_color)

    opposing_pieces.any? do |piece|
      piece.available_moves.include?(king_pos)
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
      self[*end_pos].set_new_pos_to(end_pos)
      self[*start_pos] = EmptySquare.new
      self[*end_pos].has_moved if self[*end_pos].is_a?(Pawn)
    end
  end

  def valid_move?(start_pos, end_pos)
    self[*start_pos].available_moves.include?(end_pos)
  end

  private
    attr_reader :grid

    # [Rook, Pawn].each do |piece|
    #   grid << piece.new()
    # end

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
