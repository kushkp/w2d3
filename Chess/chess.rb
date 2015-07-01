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
    input = nil
    until input == 'q'
      render_display
      input = get_user_input
      update_cursor(input)
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
