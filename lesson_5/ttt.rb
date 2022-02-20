module Formattable
  def joinor(arr, delimiter=', ', last_word='or')
    part1 = arr[0..arr.count - 2].join(delimiter)
    part2 = "#{delimiter}#{last_word} "
    return arr.last.to_s if arr.count == 1
    return arr.join(" #{last_word} ") if arr.count == 2
    part1 + part2 + arr.last.to_s
  end
end

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]
  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def reset_square(num)
    @squares[num] = Square.new(num)
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def sq5_available?
    @squares[5].unmarked?
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
    puts ""
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def identify_wincon
    wincons = {}
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      next unless about_to_win?(squares)
      marker = squares.select(&:marked?).collect(&:marker).first
      wincons[marker] = [] if wincons[marker].nil?
      wincons[marker] << squares.select(&:unmarked?).first.location
    end
    wincons
  end

  def about_to_win?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return true if markers.count == 2 && markers.uniq.count == 1
    false
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new(key) }
  end
end

class Square
  INITIAL_MARKER = " "
  attr_reader :location
  attr_accessor :marker

  def initialize(location, marker=INITIAL_MARKER)
    @location = location
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_reader :marker
  attr_accessor :score

  def initialize(marker)
    @marker = marker
    @score = 0
  end
end

class Human < Player; end

class Computer < Player
  attr_reader :board

  def initialize(marker, board)
    super(marker)
    @board = board
  end
end

class NormalComputer < Computer
  def any_threats?
    !identify_threats.empty?
  end

  def any_opportunities?
    !identify_opportunities.empty?
  end

  def identify_threats
    board.identify_wincon.reject { |k, _| k == marker }
  end

  def identify_opportunities
    board.identify_wincon.select { |k, _| k == marker }
  end

  def defense
    board[identify_threats.values.sample.sample] = marker
  end

  def offense
    board[identify_opportunities.values.first.sample] = marker
  end

  def choose_middle_square
    board[5] = marker
  end

  def choose_random
    board[board.unmarked_keys.sample] = marker
  end

  def choose
    if any_opportunities?
      offense
    elsif any_threats?
      defense
    elsif board.sq5_available?
      choose_middle_square
    else
      choose_random
    end
  end
end

class UnbeatableComputer < Computer
  def evaluation(square, is_my_turn)
    return ai_turn(square) if is_my_turn
    opponent_turn(square)
  end

  def ai_turn(square)
    value = 1000
    board[square] = marker
    return terminal_node_value(square) if terminal?
    board.unmarked_keys.each do |sq|
      value = [value, evaluation(sq, false)].min
    end
    board.reset_square(square)
    value
  end

  def opponent_turn(square)
    value = -1000
    board[square] = GameEngine::HUMAN_MARKER
    return terminal_node_value(square) if terminal?
    board.unmarked_keys.each do |sq|
      value = [value, evaluation(sq, true)].max
    end
    board.reset_square(square)
    value
  end

  def terminal_node_value(square)
    value = if board.winning_marker == marker
              100
            elsif board.winning_marker.nil?
              0
            else
              -100
            end
    board.reset_square(square)
    value
  end

  def terminal?
    board.someone_won? || board.full?
  end

  def choose
    results = {}

    board.unmarked_keys.each do |square|
      results[square] = evaluation(square, true)
    end

    possible_moves = results.select do |_, v|
      v == results.values.max
    end
    board[possible_moves.keys.sample] = marker
  end
end

class GameEngine
  include Formattable

  HUMAN_MARKER = "X"
  COMPUTER_MARKER = "O"
  FIRST_TO_MOVE = HUMAN_MARKER
  MAX_SCORE = 3

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Human.new(HUMAN_MARKER)
    @computer = if TTTGame.unbeatable
                  UnbeatableComputer.new(COMPUTER_MARKER, board)
                else
                  NormalComputer.new(COMPUTER_MARKER, board)
                end
    @current_marker = FIRST_TO_MOVE
  end

  def clear
    system 'clear'
  end

  def display_board
    puts "You're a #{human.marker}. Computer is a #{computer.marker}."
    puts "Your score: #{human.score}. Computer's score: #{computer.score}."
    puts ""
    board.draw
    puts ""
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def human_moves
    puts "Choose a square (#{joinor(board.unmarked_keys)}):"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    puts "Calculating..."
    computer.choose
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = COMPUTER_MARKER
    else
      computer_moves
      @current_marker = HUMAN_MARKER
    end
  end

  def human_turn?
    @current_marker == HUMAN_MARKER
  end

  def display_result
    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "Computer won!"
    else
      puts "It's a tie!"
    end
  end

  def update_score
    case board.winning_marker
    when human.marker
      human.score += 1
    when computer.marker
      computer.score += 1
    end
  end

  def next_round?
    answer = nil
    loop do
      puts "Would you like to play next round? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def score_reset
    human.score = 0
    computer.score = 0
  end

  def board_reset
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear
  end

  def game_reset
    score_reset
    board_reset
  end

  def grand_winner?
    human.score == MAX_SCORE || computer.score == MAX_SCORE
  end

  def announce_grand_winner
    puts "You are the Grand Winner!" if human.score == MAX_SCORE
    puts "The Grand Winner Is Computer!" if computer.score == MAX_SCORE
  end

  def new_game?
    answer = nil
    loop do
      puts "Would you like to start a new game? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end

  def player_move
    loop do
      current_player_moves
      clear_screen_and_display_board
      break if board.someone_won? || board.full?
    end
  end

  def game_round
    loop do
      display_board
      player_move
      display_result
      update_score
      break if grand_winner?
      break unless next_round?
      board_reset
      display_play_again_message
    end
  end

  def main_game
    loop do
      clear
      game_round
      announce_grand_winner if grand_winner?
      break unless grand_winner? && new_game?
      game_reset
      display_play_again_message
    end
  end
end

class TTTGame
  def initialize
    @@unbeatable = false
  end

  def self.unbeatable
    @@unbeatable
  end

  def clear
    system 'clear'
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_options
    clear
    display_welcome_message
    puts "[1]Start New Game"
    puts "[2]#{unbeatable_string} Unbeatable AI"
    puts "[3]Exit"
    puts ""
  end

  def select_option
    selection = nil
    loop do
      puts "Please select an option:"
      selection = gets.chomp
      break if ['1', '2', '3'].include? selection
      puts "Sorry, not a valid choice. Please try again."
    end
    selection
  end

  def option_execution(selection)
    case selection
    when '1'
      GameEngine.new.main_game
    when '2'
      toggle_unbeatable
    when '3'
      display_goodbye_message
    end
  end

  def unbeatable_string
    return 'Disable' if @@unbeatable
    'Enable'
  end

  def toggle_unbeatable
    @@unbeatable = !@@unbeatable
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def play
    loop do
      clear
      display_options
      selection = select_option
      option_execution(selection)
      break if selection == '3'
    end
  end
end

game = TTTGame.new
game.play
