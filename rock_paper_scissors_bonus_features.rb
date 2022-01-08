require 'yaml'

class RPSGame
  MESSAGES = YAML.load_file('rock_paper_scissors_messages.yml')
  SLEEP_DURATION = 1

  def initialize(winning_score)
    @winning_score = winning_score
    @user = User.new
    @computer = CPU.new
    @result = nil
    @history = GameHistory.new(user.name, computer.name)
  end

  private

  attr_accessor :result
  attr_reader :user, :computer, :history, :winning_score

  public

  def play
    display_welcome_message

    loop do
      determine_moves
      update_game_state
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
  end

  def determine_moves
    user.choose
    sleep(SLEEP_DURATION)
    computer.choose
    sleep(SLEEP_DURATION)
  end

  def update_game_state
    update_result
    update_scores
    history.add_match(user.move, computer.move, result)
  end

  def update_result
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
    when :user then user.increment_score
    when :computer then computer.increment_score
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
    if user.score == winning_score
      prompt("#{user.name} won the game!")
      history.display
    elsif computer.score == winning_score
      prompt("#{computer.name} won the game!")
      history.display
    end
  end

  def game_finished?
    user.score == winning_score || computer.score == winning_score
  end

  def display_goodbye_message
    message("goodbye")
  end
end

class Player
  attr_reader :name, :move, :score

  def initialize
    determine_name
    @move = nil
    @score = 0
  end

  def display_choice
    prompt("#{name} chose #{move}")
  end

  def increment_score
    self.score += 1
  end

  private

  attr_writer :name, :move, :score
end

class User < Player
  def determine_name
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
  def determine_name
    self.name = 'Computer'
  end

  def choose
    self.move = Move.new(Move::CHOICES.sample)
    display_choice
  end
end

class Move
  include Comparable

  CHOICES = %w(rock paper scissors lizard spock)
  LOSING_PAIRS = [%w(scissors lizard), %w(rock spock),
                  %w(paper lizard), %w(paper spock), %w(rock scissors)]
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

class GameHistory
  def initialize(user_name, computer_name)
    @user_name = user_name
    @computer_name = computer_name
    @matches = []
  end

  def add_match(user_move, computer_move, result)
    matches << Match.new(user_move, computer_move, result)
  end

  def display
    prompt_to_continue
    headers = column_headers
    top_line = " #{headers[0]}|#{headers[1]}|#{headers[2]}|#{headers[3]}"
    width = top_line.length
    display_title(width)
    puts top_line
    puts horizontal_rule('-', width)
    display_matches(headers.map(&:length))
    puts horizontal_rule('-', width)
  end

  def column_headers
    [" Match # ", " #{user_name}'s moves ", " #{computer_name}'s moves ",
     "  Winner  "]
  end

  def display_title(width)
    puts "GAME HISTORY".center(width)
    puts horizontal_rule(' ', width)
  end

  def display_matches(column_widths)
    matches.each_with_index do |match, index|
      match.display(index + 1, column_widths)
    end
  end

  private

  attr_reader :user_name, :computer_name, :matches
end

class Match
  def initialize(user_move, computer_move, result)
    @user_move = user_move
    @computer_move = computer_move
    @result = result
  end

  def display(match_number, column_widths)
    row = [" #{match_number.to_s.center(column_widths[0])}",
           "|#{user_move.to_s.center(column_widths[1])}",
           "|#{computer_move.to_s.center(column_widths[2])}",
           "| #{result}"]
    puts row.join
  end

  private

  attr_reader :user_move, :computer_move, :result
end

# HELPER METHODS

def message(message_key)
  prompt(RPSGame::MESSAGES[message_key])
end

def prompt(message)
  puts "==> #{message}"
end

def prompt_to_continue
  message("continue_game")
  gets
  system('clear')
end

def horizontal_rule(char, length)
  char * length
end

# GAME INITIALIZATION

CUSTOM_WINNING_SCORE = 3
RPSGame.new(CUSTOM_WINNING_SCORE).play
