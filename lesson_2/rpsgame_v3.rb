require 'io/console'

module Verifiable
  VALID_MOVE_INPUT = { 'r' => 'rock',
                       'p' => 'paper',
                       's' => 'scissors',
                       'l' => 'lizard',
                       'sp' => 'spock' }
  YES_AND_NO = { 'y' => 'yes',
                 'n' => 'no' }
  VALID_MENU_INPUT = { '1' => 'new game',
                       '2' => 'rules',
                       '3' => 'history',
                       '4' => 'exit' }

  def valid?(input, valid_values)
    (valid_values.keys + valid_values.values).include? input
  end

  def map_shortcut(input, valid_values)
    return valid_values[input] if valid_values.keys.include? input
    input
  end

  def start_with_space?(input)
    input[0] == ' '
  end
end

class Move
  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']
  attr_reader :value

  def to_s
    @value
  end

  def ==(other_move)
    self.class == other_move.class
  end
end

class Rock < Move
  def initialize
    @value = 'rock'
  end

  def >(other_move)
    other_move.class == Scissors || other_move.class == Lizard
  end
end

class Paper < Move
  def initialize
    @value = 'paper'
  end

  def >(other_move)
    other_move.class == Rock || other_move.class == Spock
  end
end

class Scissors < Move
  def initialize
    @value = 'scissors'
  end

  def >(other_move)
    other_move.class == Paper || other_move.class == Lizard
  end
end

class Lizard < Move
  def initialize
    @value = 'lizard'
  end

  def >(other_move)
    other_move.class == Paper || other_move.class == Spock
  end
end

class Spock < Move
  def initialize
    @value = 'spock'
  end

  def >(other_move)
    other_move.class == Rock || other_move.class == Scissors
  end
end

class Score
  attr_accessor :value

  MAX = 3
  def initialize
    @value = 0
  end

  def increase
    self.value += 1
  end

  def reset
    self.value = 0
  end
end

class History
  attr_accessor :history, :game_count

  def initialize
    @history = {}
    @game_count = 0
  end

  def add(player, computer)
    player_record = [player.name, player.move, computer.name, computer.move]
    score_record = [player.read_score, computer.read_score]
    history[game_count] << player_record + score_record
  end

  def display
    history.each do |count, records|
      puts "Game #{count}:"
      records.each do |record|
        player_move = "#{record[0]} chose #{record[1]}"
        computer_move = "#{record[2]} chose #{record[3]}"
        score = "Score: #{record[4]}-#{record[5]}"
        puts "#{player_move}, #{computer_move}. #{score}"
      end
      puts ""
    end
  end

  def new_entry
    self.game_count += 1
    history[game_count] = []
  end

  def nothing?
    history.empty?
  end
end

class Player
  attr_accessor :move, :name
  attr_reader :score

  def initialize
    set_name
    @score = Score.new
  end

  def make_move(choice)
    return Rock.new if choice == 'rock'
    return Paper.new if choice == 'paper'
    return Scissors.new if choice == 'scissors'
    return Lizard.new if choice == 'lizard'
    return Spock.new if choice == 'spock'
  end

  def read_score
    score.value
  end
end

class Human < Player
  include Verifiable

  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty? || start_with_space?(n)
      puts "Sorry, must enter a valid value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Plese choose: [R]ock, [P]aper, [S]cissors, [L]izard or [Sp]ock"
      choice = gets.chomp.downcase
      break if valid?(choice, Verifiable::VALID_MOVE_INPUT)
      puts "Sorry, invalid choice"
    end
    choice = map_shortcut(choice, Verifiable::VALID_MOVE_INPUT)
    self.move = make_move(choice)
  end
end

class Computer < Player
  ROBOTS = ['R2D2', 'Hal', 'Chappie', 'Number 5']

  def choose
    self.move = make_move(Move::VALUES.sample)
  end
end

class R2d2 < Computer
  def set_name
    self.name = 'R2D2'
  end

  def choose
    self.move = make_move('rock')
  end
end

class Hal < Computer
  def set_name
    self.name = 'Hal'
  end

  def choose
    randomizer = rand(1..10)
    self.move = if randomizer > 3
                  make_move('spock')
                else
                  make_move('lizard')
                end
  end
end

class Chappie < Computer
  def set_name
    self.name = 'Chappie'
  end

  def choose
    choice = nil
    loop do
      choice = Move::VALUES.sample
      break unless choice == 'scissors'
    end
    self.move = make_move(choice)
  end
end

class Number5 < Computer
  def set_name
    self.name = 'Number5'
  end

  def choose
    if read_score == Score::MAX - 1
      self.move = 'paper'
    else
      super
    end
  end
end

class RPSLSGame
  include Verifiable

  MENU = { '1' => 'New Game',
           '2' => 'Rules',
           '3' => 'History',
           '4' => 'Exit' }
  RULES = <<-MSG
  Rock Paper Scissors Lizard Spock is an extension of the classic game of chance, Rock Paper Scissors, created by Sam Kass and Karen Bryla.

  Game rules:
  Scissors cuts paper, paper covers rock, rock crushes lizard, lizard poisons Spock, Spock smashes scissors,
  scissors decapitates lizard, lizard eats paper, paper disproves Spock, Spock vaporizes rock, and rock crushes scissors.
  MSG

  attr_reader :human, :computer, :history

  def initialize
    system 'clear'
    @human = Human.new
    @computer = select_computer
    @history = History.new
  end

  def play
    loop do
      display_menu
      choice = choose_menu_item
      execute_menu_item(choice)
      break if choice == '4'
    end
  end

  private

  def display_welcome_message
    system 'clear'
    puts "Welcome to Rock/Paper/Scissors/Lizard/Spock, #{human.name}!"
    puts "Today's random opponent is: #{computer.name}"
  end

  def display_goodbye_message
    puts "Thanks for playing RPSLS. Goodbye!"
  end

  def select_computer
    selection = Computer::ROBOTS.sample
    return R2d2.new if selection == 'R2D2'
    return Hal.new if selection == 'Hal'
    return Chappie.new if selection == 'Chappie'
    return Number5.new if selection == 'Number 5'
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? [Y]es/[N]o"
      answer = gets.chomp.downcase
      break if valid?(answer, Verifiable::YES_AND_NO)
      puts "Sorry, must be yes or no."
    end

    return true if ['y', 'yes'].include? answer
    false
  end

  def display_rules
    system 'clear'
    puts RULES
    puts ""
    puts "[Press any key to return...]"
    STDIN.getch
  end

  def exit_game
    display_goodbye_message
  end

  def display_history
    system 'clear'
    if history.nothing?
      puts "No recent play history."
    else
      history.display
    end
    puts ""
    puts "[Press any key to return...]"
    STDIN.getch
  end

  def display_menu
    system 'clear'
    display_welcome_message
    puts ""
    MENU.each do |num, title|
      puts "[#{num}] #{title}"
    end
  end

  def choose_menu_item
    choice = nil
    loop do
      display_menu
      puts ""
      puts "Please choose one of the options:"
      choice = gets.chomp
      break if valid?(choice, Verifiable::VALID_MENU_INPUT)
      puts "Sorry, invalid choice"
    end
    choice
  end

  def execute_menu_item(choice)
    case choice
    when "1"
      start_new_game
    when "2"
      display_rules
    when "3"
      display_history
    when "4"
      exit_game
    end
  end

  def start_new_game
    loop do
      system 'clear'
      GameEngine.new(human, computer, history).game_loop
      break unless play_again?
    end
  end
end

class GameEngine
  attr_reader :human, :computer, :game_history

  def initialize(human, computer, history)
    @human = human
    @computer = computer
    @game_history = history
    human.score.reset
    computer.score.reset
    game_history.new_entry
  end

  def game_loop
    loop do
      display_score
      human.choose
      computer.choose
      display_result
      break if grand_winner?
      next_round
    end
    display_grand_winner
  end

  private

  def display_choice
    puts ""
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def decide_winner
    return human if human.move > computer.move
    return nil if human.move == computer.move
    computer
  end

  def display_round_winner
    puts ""
    case decide_winner
    when human
      puts "#{human.name} won!"
    when computer
      puts "#{computer.name} won!"
    when nil
      puts "It's a tie!"
    end
  end

  def update_score
    case decide_winner
    when human
      human.score.increase
    when computer
      computer.score.increase
    end
  end

  def update_history
    game_history.add(human, computer)
  end

  def display_score
    system 'clear'
    puts "#{human.name}'s score: #{human.read_score}."
    puts "#{computer.name}'s score: #{computer.read_score}."
    puts ""
  end

  def grand_winner?
    human.read_score == Score::MAX || computer.read_score == Score::MAX
  end

  def display_grand_winner
    if human.read_score == Score::MAX
      puts "The Grand Winner is #{human.name}!"
    else
      puts "The Grand Winner is #{computer.name}!"
    end
  end

  def next_round
    puts "[Press any key to start next round...]"
    STDIN.getch
  end

  def display_result
    display_choice
    decide_winner
    update_score
    display_round_winner
    update_history
  end
end

RPSLSGame.new.play
