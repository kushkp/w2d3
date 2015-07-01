
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
    while board.empty_on_board?(next_pos)
      avail_pos << next_pos
      next_pos = [next_pos[0] + (dr * direction), next_pos[1] + (dc * direction)]
    end

    if opponent_at?(next_pos)
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

  private
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

  private
    def vertical_moves
      get_moves(:vertical)
    end

    def horizontal_moves
      get_moves(:horizontal)
    end
end

module SteppingPiece
  def available_moves
    moves = []
    @deltas.each do |delta|
      new_pos = [delta[0] + pos[0], delta[1] + pos[1]]
      if opponent_at?(new_pos) || board.empty_on_board?(new_pos)
        moves << new_pos
      end
    end
    
    moves
  end
end
