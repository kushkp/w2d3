require_relative "board"
require_relative "display"
require_relative "player"

require "io/console"

class Game
  attr_reader :board, :display
  def initialize
    @board = Board.new
    player1 = Player.new(:black)
    player2 = Player.new(:white)
    @players = [player1, player2]
    @display = Display.new(@board, player1)
  end

  def current_player
    @players.first
  end

  def play
    until winner
      render_display
      input = current_player.get_user_input
      update_cursor(input)
      change_turns if board.move_made
      break if input =='q'
    end

    print_winning_message
  end

  private
    def change_turns
      @players.rotate!
      @display.current_player = current_player
      @board.move_made = false
    end

    def winner
      if @board.checkmate?(:white)
        return :black
      elsif @board.checkmate?(:black)
        return :white
      else
        nil
      end
    end

    def print_winning_message
      puts "Congrats! #{winner} wins!"
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
