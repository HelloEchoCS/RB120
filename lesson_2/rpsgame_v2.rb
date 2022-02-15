# Score as a class

class Move
  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']
  RULES = { rock: [:scissors, :lizard],
            paper: [:rock, :spock],
            scissors: [:paper, :lizard],
            lizard: [:spock, :paper],
            spock: [:rock, :scissors] }

  attr_reader :value

  def initialize(value)
    @value = value
  end

  def >(other_move)
    RULES[value.to_sym].include?(other_move.value.to_sym)
  end

  def ==(other_move)
    value == other_move.value
  end

  def to_s
    @value
  end

  def self.options
    VALUES.join(", ")
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

class Player
  attr_accessor :move, :name
  attr_reader :score

  def initialize
    set_name
    @score = Score.new
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
      puts "Plese choose from #{Move.options}:"
      choice = gets.chomp
      break if Move::VALUES.include? choice
      puts "Sorry, invalid choice"
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class RPSLSGame
  attr_reader :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors. Good bye!"
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

  def play
    display_welcome_message
    loop do
      Round.new(human, computer).game_loop
      break unless play_again?
    end
    display_goodbye_message
  end
end

class Round
  attr_reader :human, :computer

  def initialize(human, computer)
    @human = human
    @computer = computer
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

  def display_score
    puts "#{human.name}'s score: #{human.score.value}."
    puts "#{computer.name}'s score: #{computer.score.value}."
  end

  def grand_winner?
    human.score.value == Score::MAX || computer.score.value == Score::MAX
  end

  def display_grand_winner
    if human.score.value == Score::MAX
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

  def game_loop
    loop do
      human.choose
      computer.choose
      display_result
      break if grand_winner?
    end
    display_grand_winner
  end
end

RPSLSGame.new.play
