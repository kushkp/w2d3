DICTIONARY = File.readlines('dictionary.txt').map { |word| word.chomp }

class Hangman
  attr_accessor :guessing_player, :checking_player
  def initialize(guessing_player,checking_player)
    @guessing_player, @checking_player = guessing_player, checking_player
    @guesses = []
  end

  def play
    checking_player.pick_secret_word
    guessing_player.receive_secret_length(checking_player.encoded.length)
    until !checking_player.encoded.include?("_")
      puts "Secret word: #{checking_player.encoded}"
      guess = guessing_player.guess
      result = checking_player.check_guess(guess)
      checking_player.handle_guess_response(result)

    end
    puts "YOU WIN! Word was #{checking_player.encoded}"
  end
end

class HumanPlayer
  attr_accessor :secret_word, :encoded

  def initialize
    @current_guess = ""
    @encoded = ""
    @length_of_word = nil
  end

  def pick_secret_word
    puts "Enter the length of your secret word:"
   # @secret_word = gets.chomp.downcase
    @encoded = "_" * gets.chomp.to_i
  end

  def receive_secret_length(num)
    @length_of_word = num
  end

  def guess
    puts "Please enter a letter:"
    gets.chomp.downcase
  end

  def check_guess(letter)
    @current_guess = letter
    begin
      puts "Is #{letter} in your word? (y/n)"
    rescue
      input = gets.chomp.downcase
      raise ArgumentError.new("Invalid input") unless ["y","n"].include?(input)
      retry
    end
      in_word = (input == "y")
      if in_word
        begin
          puts "Enter the positions of #{letter} in your word:"
        rescue
          indices = gets.chomp.split(" ").map {|num| num.to_i }
          retry if indices.any? { |el| !el.is_a?(Fixnum) }
        end
      return indices
    end
    in_word
  end

  def handle_guess_response(check_guess_result)
    return if check_guess_result == false
    check_guess_result.each do |idx|
      encoded[idx-1] = @current_guess
    end
  end
end

class ComputerPlayer

  attr_accessor :secret_word, :encoded

  def initialize
    @secret_word = ""
    @encoded = "_" * @secret_word.length
    @length_of_word = nil
    @possible_guesses = []
    @eliminated_letters = []
    @guessed_letters = []
  end

  def pick_secret_word
    @secret_word = DICTIONARY.sample
    @encoded = "_" * @secret_word.length
  end

  def receive_secret_length(num)
    @length_of_word = num
    @possible_guesses = DICTIONARY.select {|word| word.length == @length_of_word}
  end

  def guess
    #p @possible_guesses
    words_without_elim_letters = @possible_guesses.reject do |word|
      word.chars.any? { |letter| @eliminated_letters.include?(letter) }
    end

    #long_string = words_without_elim_letters.inject(:+)
    #puts long_string
    frequencies = {}
    words_without_elim_letters.each do |word|
      word.chars.each do |letter|
        frequencies.keys.include?(letter) ? frequencies[letter] += 1 : frequencies[letter] = 1 unless @guessed_letters.include?(letter)
      end
    end
    p frequencies
    letter = frequencies.sort_by {| _, value| value }.last[0]
    @guessed_letters << letter
    letter
  end

  def check_guess(letter)
    secret_word.match(letter) ? secret_word.index(letter) : @eliminated_letters << letter
  end

  def handle_guess_response(check_guess_result)
    if check_guess_result.is_a?(Fixnum)
      letter = secret_word[check_guess_result]
      secret_word.chars.each_with_index { |let, idx| encoded[idx] = let if let == letter }
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  human = HumanPlayer.new
  human2 = HumanPlayer.new
  computer = ComputerPlayer.new
  computer2 = ComputerPlayer.new

  game = Hangman.new(human2, human)
  game.play
end
