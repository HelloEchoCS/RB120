module Displayable
  def joinor(arr, delimiter=', ', last_word='or')
    part1 = arr[0..arr.count - 2].join(delimiter)
    part2 = "#{delimiter}#{last_word} "
    return arr.last.to_s if arr.count == 1
    return arr.join(" #{last_word} ") if arr.count == 2
    part1 + part2 + arr.last.to_s
  end

  def clear
    system 'clear'
  end
end

module Validatable
  def valid?(input, criteria=nil)
    return false if input.to_s.empty?
    return criteria.include? input if criteria
    true
  end

  def start_with_space?(input)
    input[0] == " "
  end
end

class String
  def red
    "\e[31m#{self}\e[0m"
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

  def markers
    @squares.values.select(&:marked?).collect(&:marker)
  end

  def sq5_available?
    @squares[5].unmarked?
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def draw
    puts "1    |2    |3"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "4    |5    |6"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "7    |8    |9"
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
    @marker.red
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_accessor :score, :marker, :name

  def initialize
    @score = 0
  end
end

class Human < Player; end

class Computer < Player
  attr_reader :board

  def initialize(board)
    super()
    @board = board
  end

  private

  def identify_opponent_marker
    board.markers.reject { |m| m == marker }.first
  end

  def choose_middle_square
    board[5] = marker
  end
end

class NormalComputer < Computer
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

  private

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

  def choose_random
    board[board.unmarked_keys.sample] = marker
  end
end

class UnbeatableComputer < Computer
  def choose
    if board.sq5_available?
      choose_middle_square
    else
      choose_best_outcome
    end
  end

  private

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
    board[square] = identify_opponent_marker
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

  def choose_best_outcome
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

class Config
  attr_accessor :unbeatable,
                :human_marker,
                :computer_marker,
                :human_name,
                :computer_name

  def initialize
    @unbeatable = false
    @human_marker = "X"
    @computer_marker = "O"
    @human_name = "Human"
    @computer_name = "Computer"
  end
end

class GameEngine
  include Displayable
  include Validatable
  MAX_SCORE = 3

  def initialize(config)
    @config = config
    @board = Board.new
    @human = Human.new
    @computer = if config.unbeatable
                  UnbeatableComputer.new(board)
                else
                  NormalComputer.new(board)
                end
    load_names_and_markers
    @current_marker = human.marker
  end

  def main_game
    loop do
      clear
      game_round
      announce_grand_winner if grand_winner?
      break unless grand_winner? && new_game?
      game_reset
    end
  end

  private

  attr_reader :board, :human, :computer, :config

  def load_names_and_markers
    human.name = config.human_name
    computer.name = config.computer_name
    human.marker = config.human_marker
    computer.marker = config.computer_marker
  end

  def display_markers
    human_marker_str = "#{human.name}[#{human.marker}]"
    computer_marker_str = "#{computer.name}[#{computer.marker}]"
    puts "Marker: #{human_marker_str} | #{computer_marker_str}"
  end

  def display_scores
    human_score_str = "#{human.name}[#{human.score}]"
    computer_score_str = "#{computer.name}[#{computer.score}]"
    puts "Score:  #{human_score_str} | #{computer_score_str}"
  end

  def display_board
    display_markers
    display_scores
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
      break if valid?(square, board.unmarked_keys)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    puts "#{computer.name} is thinking..."
    sleep 1
    computer.choose
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = computer.marker
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def human_turn?
    @current_marker == human.marker
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
      break if valid?(answer, %w(y n))
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
    @current_marker = human.marker
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
    puts "The Grand Winner Is #{computer.name}!" if computer.score == MAX_SCORE
  end

  def new_game?
    answer = nil
    loop do
      puts "Would you like to start a new game? (y/n)"
      answer = gets.chomp.downcase
      break if valid?(answer, %w(y n))
      puts "Sorry, must be y or n"
    end

    answer == 'y'
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
    end
  end
end

class TTTGame
  include Displayable
  include Validatable

  def initialize
    @config = Config.new
  end

  def play
    loop do
      clear
      display_options
      selection = select_option
      option_execution(selection)
      break if selection == '4'
    end
  end

  private

  attr_reader :config

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_options
    clear
    display_welcome_message
    menu_items.each { |k, v| puts "[#{k}] #{v}" }
    puts ""
  end

  def menu_items
    { '1' => "Start New Game",
      '2' => "#{unbeatable_string} Unbeatable AI",
      '3' => "Customize Player Profiles",
      '4' => "Exit" }
  end

  def select_option
    selection = nil
    loop do
      puts "Please select an option:"
      selection = gets.chomp
      break if valid?(selection, menu_items.keys)
      puts "Sorry, not a valid choice. Please try again."
    end
    selection
  end

  def option_execution(selection)
    case selection
    when '1'
      GameEngine.new(config).main_game
    when '2'
      toggle_unbeatable
    when '3'
      customize_markers
    when '4'
      display_goodbye_message
    end
  end

  def customize_markers
    clear
    change_human_name
    change_human_marker
    change_computer_name
    change_computer_marker
  end

  def change_human_marker
    marker = nil
    loop do
      puts "Please enter your marker (current: #{config.human_marker})"
      marker = gets.chomp.upcase
      break if marker.length == 1 && !start_with_space?(marker)
      puts "Invalid marker, must be one-character long."
    end
    config.human_marker = marker
  end

  def change_computer_marker
    marker = nil
    loop do
      marker = request_computer_marker
      break unless marker == config.human_marker
      puts "Computer marker cannot be the same as yours."
    end
    config.computer_marker = marker
  end

  def change_human_name
    name = nil
    loop do
      puts "Please enter your name (current: #{config.human_name})"
      name = gets.chomp
      break if valid?(name)
      puts "Invalid name, please try again."
    end
    config.human_name = name
  end

  def change_computer_name
    name = nil
    loop do
      name = request_computer_name
      break unless name == config.human_name
      puts "Computer name cannot be the same as yours."
    end
    config.computer_name = name
  end

  def request_computer_name
    name = nil
    loop do
      puts "Please enter computer's name (current: #{config.computer_name})"
      name = gets.chomp
      break if valid?(name)
      puts "Invalid name, please try again."
    end
    name
  end

  def request_computer_marker
    marker = nil
    loop do
      name = config.computer_name
      puts "Please enter #{name}'s marker (current: #{config.computer_marker})"
      marker = gets.chomp.upcase
      break if marker.length == 1 && !start_with_space?(marker)
      puts "Invalid marker, must be one-character long."
    end
    marker
  end

  def unbeatable_string
    return 'Disable' if config.unbeatable
    'Enable'
  end

  def toggle_unbeatable
    config.unbeatable = !config.unbeatable
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end
end

game = TTTGame.new
game.play
