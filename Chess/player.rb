class Player
  require "io/console"
  attr_reader :color
  def initialize(color)
    @color = color

  end

  def get_user_input
    $stdin.getch
  end

end
