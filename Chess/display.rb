require 'colorize'

class Display
  attr_reader :board, :debugger
  MOVEMENTS = { "w" => [-1,0],
                "d" => [0,1],
                "s" => [1,0],
                "a" => [0,-1],
                "\r" => [0,0] }

  def initialize(board)
    @board = board
    @cursor = [0,0]
    @debugger = true
  end

  def render
    system("clear")
    board.size.times do |r|
      board.size.times do |c|
        print color(r, c, board[r, c])
      end
      print "\n"
    end

    print_debug if debugger
  end

  def update(input)
    return unless valid?(input)
    self.cursor = new_pos(input)
  end

  private
  attr_accessor :cursor

  def color(r, c, square)
    if cursor == [r, c]
      " #{square.to_s} ".colorize(background: :yellow)
    elsif board[*cursor].available_moves.include?([r,c])
      " #{square.to_s} ".colorize(background: :green)
    elsif (r+c).even?
      " #{square.to_s} ".colorize(background: :blue)
    else
      " #{square.to_s} ".colorize(background: :magenta)
    end
  end

  def print_debug
    puts "cursor at: #{cursor} "
    puts "current square: #{@board[*cursor]} "
    puts "available_moves #{@board[*cursor].available_moves} "
    puts "Current object: #{@board[*cursor].inspect}"
  end

  def new_pos(input)
    change = MOVEMENTS[input]
    [cursor[0] + change[0], cursor[1] + change[1]]
  end

  def result_on_board(input)
    Board.on_board?(new_pos(input))
  end

  def valid?(input)
    MOVEMENTS.has_key?(input) && result_on_board(input)
  end



end
