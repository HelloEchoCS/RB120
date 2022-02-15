# Score as a class
# RPSLS are different classes
class Move
  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']

  attr_reader :value

  def to_s
    @value
  end

  def ==(other_move)
    self.class == other_move.class
  end

  def self.options
    VALUES.join(", ")
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
    end
  end

  def new_entry
    self.game_count += 1
    history[game_count] = []
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
  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Plese choose: #{Move.options}:"
      choice = gets.chomp
      break if Move::VALUES.include? choice
      puts "Sorry, invalid choice"
    end
    self.move = make_move(choice)
  end
end

class Computer < Player
  ROBOTS = ['R2D2', 'Hal', 'Chappie', 'Number 5']

  def choose
    self.move = Move.new(Move::VALUES.sample)
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
    randomizer = [1..10].sample
    self.move = if randomizer > 2
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
  attr_reader :human, :computer, :history

  def initialize
    @human = Human.new
    @computer = select_computer
    @history = History.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock!"
    puts "Your opponent is: #{computer.name}"
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
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include? answer.downcase
      puts "Sorry, must be y or n."
    end

    return true if answer.downcase == 'y'
    false
  end

  def new_game
    history.display
    history.new_entry
    Game.new(human, computer, history).main_loop
  end

  def play
    display_welcome_message
    loop do
      new_game
      break unless play_again?
    end
    display_goodbye_message
  end
end

class Game
  attr_reader :human, :computer, :game_history

  def initialize(human, computer, history)
    @human = human
    @computer = computer
    @game_history = history
    human.score.reset
    computer.score.reset
  end

  def display_choice
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def decide_winner
    return human if human.move > computer.move
    return nil if human.move == computer.move
    computer
  end

  def display_round_winner
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

  def record_history
    game_history.add(human, computer)
  end

  def display_score
    puts "#{human.name}'s score: #{human.read_score}."
    puts "#{computer.name}'s score: #{computer.read_score}."
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

  def display_result
    display_choice
    decide_winner
    update_score
    display_round_winner
    display_score
  end

  def main_loop
    loop do
      human.choose
      computer.choose
      display_result
      record_history
      break if grand_winner?
    end
    display_grand_winner
  end
end

RPSLSGame.new.play
