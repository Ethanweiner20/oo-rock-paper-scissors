# Rock Paper Scissors: Using a `Move` class

require 'yaml'

class RPSGame
  MESSAGES = YAML.load_file('rock_paper_scissors_messages.yml')
  WINNING_SCORE = 3

  attr_accessor :result
  attr_reader :user, :computer

  def initialize
    @user = User.new
    @computer = CPU.new
    @result = nil
  end

  def play
    display_welcome_message

    loop do
      system('clear')
      determine_moves
      set_result
      update_scores
      display_game_info
      break if game_finished?
      prompt_to_continue
    end

    display_goodbye_message
  end

  def display_welcome_message
    system('clear')
    message("welcome")
    prompt_to_continue
    system('clear')
  end

  def determine_moves
    user.choose
    computer.choose
  end

  def set_result
    self.result = if user.move > computer.move
                    :user
                  elsif user.move < computer.move
                    :computer
                  else
                    :tie
                  end
  end

  def update_scores
    case result
    when :user then user.score += 1
    when :computer then computer.score += 1
    end
  end

  def display_game_info
    display_result
    display_score
    display_game_end
  end

  def display_result
    prompt(result_message)
  end

  def result_message
    case result
    when :user then "#{user.name} won!"
    when :tie then "#{user.name} tied with #{computer.name}"
    when :computer then "#{computer.name} won!"
    end
  end

  def display_score
    prompt("SCORE: #{user.score} (#{user.name}) "\
           "to #{computer.score} (#{computer.name})")
  end

  def display_game_end
    if user.score == WINNING_SCORE
      prompt("#{user.name} won the game!")
    elsif computer.score == WINNING_SCORE
      prompt("#{computer.name} won the game!")
    end
  end

  def game_finished?
    user.score == WINNING_SCORE || computer.score == WINNING_SCORE
  end

  def display_goodbye_message
    message("goodbye")
  end
end

class Player
  attr_accessor :move, :score
  attr_reader :name

  def initialize
    set_name
    @score = 0
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

  CHOICES = ['rock', 'paper', 'scissors', 'lizard', 'spock']
  LOSING_PAIRS = [['scissors', 'lizard'], ['rock', 'spock'],
                  ['paper', 'lizard'], ['paper', 'spock'], ['rock', 'scissors']]
  WINNING_COMBINATIONS = CHOICES.zip(LOSING_PAIRS).to_h

  def initialize(choice)
    @choice = choice
  end

  def <=>(other_move)
    if tie?(other_move)
      0
    elsif win?(other_move)
      1
    else
      -1
    end
  end

  def tie?(other_move)
    choice == other_move.choice
  end

  def win?(other_move)
    WINNING_COMBINATIONS[choice].include?(other_move.choice)
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

def prompt_to_continue
  message("continue_game")
  gets
end

RPSGame.new.play
