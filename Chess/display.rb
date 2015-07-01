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
    @selection_queue = []
    @selected_square = nil
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
    new_cursor = new_pos(input)
    self.cursor = new_cursor if result_on_board(new_cursor)
  end

  private
  attr_accessor :cursor

  def color(r, c, square)
    bg_color = alternating_colors(r, c)

    if cursor == [r, c]
      bg_color = :yellow
    elsif in_available_moves?(r, c)
      if board[r, c].empty?
        bg_color = :green
      else
        bg_color = :red
      end
    end

    " #{square.to_s} ".colorize(background: bg_color)
  end

  def alternating_colors(row,col)
    (row + col).even? ? :blue : :magenta
  end

  def in_available_moves?(row, col)
    if @selected_square.nil?
      board[*cursor].available_moves.include?([row, col])
    else
      board[*@selected_square].available_moves.include?([row, col])
    end
  end

  def print_debug
    puts "cursor at: #{cursor} "
    puts "current square: #{@board[*cursor]} "
    puts "available_moves #{@board[*cursor].available_moves} "
    puts "Current object: #{@board[*cursor].inspect}"
    puts "Selection Queue: #{@selection_queue}"
    puts "Find King black: #{@board.find_king(:black)}"
    puts "Find King white: #{@board.find_king(:white)}"
    puts "all Pieces: #{@board.all_pieces(@board[*cursor].color)}"
    puts "Black King in Check?: #{@board.in_check?(:black)}"
    puts "White King in Check?: #{@board.in_check?(:white)}"

  end

  def new_pos(input)
    change = MOVEMENTS[input]
    if input == "\r"
      @selection_queue << cursor.dup
      handle_selection_queue
      cursor
    else
      [cursor[0] + change[0], cursor[1] + change[1]]
    end
  end

  def handle_selection_queue
    return if @selection_queue.empty?
    if @selection_queue.size >= 2
      board.move(@selection_queue.shift, @selection_queue.shift)
      @selected_square = nil
    elsif @selection_queue.size == 1
      @selected_square = @selection_queue.first
    end
  end

  def result_on_board(pos)
    board.on_board?(pos)
  end

  def valid?(input)
    MOVEMENTS.has_key?(input)
  end



end
