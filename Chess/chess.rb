require_relative "board"
require_relative "display"
require "io/console"

class Game
  attr_reader :board, :display
  def initialize
    @board = Board.new
    @display = Display.new(@board)
  end

  def play
    loop do
      render_display
      input = get_user_input
      update_cursor(input)
      break if input =='q'
    end
  end

  private
    def get_user_input
      $stdin.getch
    end

    def render_display
      @display.render
    end

    def update_cursor(input)
      @display.update(input)
    end
end

if __FILE__ == $PROGRAM_NAME
  g = Game.new
  # g.board[4, 4] = g.board[7, 4]
  # g.board[7, 4] = EmptySquare.new
  # g.board[2, 3] = g.board[1, 3]
  # g.board[1, 3] = EmptySquare.new
  g.play
end
