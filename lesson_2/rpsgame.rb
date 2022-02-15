# store scores as state in Player instances

class Move
  VALUES = ['rock', 'paper', 'scissors']

  def initialize(value)
    @value = value
  end

  def scissors?
    @value == 'scissors'
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def >(other_move)
    (rock? && other_move.scissors?) ||
      (paper? && other_move.rock?) ||
      (scissors? && other_move.paper?)
  end

  def <(other_move)
    (rock? && other_move.paper?) ||
      (paper? && other_move.scissors?) ||
      (scissors? && other_move.rock?)
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = 0
  end

  def increse_score
    self.score += 1
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
      puts "Plese choose rock, paper, or scissors:"
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

class RPSGame
  attr_accessor :human, :computer

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

  def display_choice
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def decide_winner
    return human if human.move > computer.move
    return computer if human.move < computer.move
    nil
  end

  def display_round_winner
    case decide_winner
    when human
      puts "#{human.name} won!"
      human.increse_score
    when computer
      puts "#{computer.name} won!"
      computer.increse_score
    when nil
      puts "It's a tie!"
    end
  end

  def display_score
    puts "#{human.name}'s score: #{human.score}"
    puts "#{computer.name}'s score: #{computer.score}"
  end

  def grand_winner?
    human.score == 3 || computer.score == 3
  end

  def display_grand_winner
    if human.score == 3
      puts "The Grand Winner is #{human.name}!"
    else
      puts "The Grand Winner is #{computer.name}!"
    end
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

  def game_loop
    loop do
      human.choose
      computer.choose
      display_choice
      decide_winner
      display_round_winner
      display_score
      break if grand_winner?
    end
  end

  def play
    display_welcome_message
    loop do
      game_loop
      display_grand_winner
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
