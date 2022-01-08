# Rock Paper Scissors: Using a `Move` class

require 'yaml'

class RPSGame
  MESSAGES = YAML.load_file('rock_paper_scissors_messages.yml')

  attr_reader :user, :computer

  def initialize
    @user = User.new
    @computer = CPU.new
  end

  def play
    display_welcome_message

    loop do
      system('clear')
      user.choose
      computer.choose
      display_result
      break unless play_again?
    end

    display_goodbye_message
  end

  def display_welcome_message
    system('clear')
    message("welcome")
    gets
    system('clear')
  end

  def display_result
    prompt(result_message)
  end

  def result_message
    case user.move <=> computer.move
    when -1 then "#{user.name} won!"
    when 0 then "#{user.name} tied with #{computer.name}"
    when 1 then "#{computer.name} won!"
    end
  end

  def play_again?
    answer = nil

    loop do
      message("play_again")
      answer = gets.chomp.downcase
      break if %(y n).include?(answer)
      message("invalid_input")
    end

    answer == 'y'
  end

  def display_goodbye_message
    message("goodbye")
  end
end

class Player
  attr_accessor :move
  attr_reader :name

  def initialize
    set_name
  end

  def display_choice
    prompt("#{name} chose #{move}")
  end

  private

  attr_writer :name
end

class User < Player
  def set_name
    system('clear')
    name = ''

    loop do
      message("choose_name")
      name = gets.chomp.strip
      break unless name.empty?
      message("invalid_input")
    end

    self.name = name
  end

  def choose
    message("choices")
    choice = retrieve_choice
    self.move = Move.new(choice)
    display_choice
  end

  def retrieve_choice
    choice = nil

    loop do
      choice = gets.chomp.downcase
      break if Move::CHOICES.include?(choice)
      message("invalid_input")
    end

    choice
  end
end

class CPU < Player
  def set_name
    self.name = 'Computer'
  end

  def choose
    self.move = Move.new(Move::CHOICES.sample)
    display_choice
  end
end

class Move
  include Comparable

  CHOICES = ['rock', 'paper', 'scissors']
  WINNING_COMBINATIONS = CHOICES.zip(['scissors', 'rock', 'paper']).to_h

  def initialize(choice)
    @choice = choice
  end

  def <=>(other_move)
    if tie?(other_move)
      0 # moves are equivalent
    elsif win?(other_move)
      1 # self is better
    else
      -1 # other_move is better
    end
  end

  def tie?(other_move)
    choice == other_move.choice
  end

  def win?(other_move)
    WINNING_COMBINATIONS[choice] == other_move.choice
  end

  def to_s
    choice
  end

  protected

  attr_reader :choice
end

# Helpers

def message(message_key)
  prompt(RPSGame::MESSAGES[message_key])
end

def prompt(message)
  puts "==> #{message}"
end

RPSGame.new.play
