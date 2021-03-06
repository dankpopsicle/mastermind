class Mastermind
  def initialize
    @player_creator = 0
    @player_role = 0
    @four_values = 0
    @guess_value = 0
    @guess_key = 0
    @code_value = 0
    @turn_number = 0
    @round_number = 0
    @player_score = 0
    @computer_score = 0
    @gameboard = create_board
    @value_only = 0
    @combo_value_only = 0
    @value_location = 0
    @combo_value_location = 0
    @round_over = false
    @all_combinations = 0
    @potential_combinations = 0
    @new_combinations = []
    @play_again_yes = 0
  end

  def create_board
    @gameboard = Array.new(12).map do |x|
      x = "- - - -"
    end
  end

  def puts_board
    @gameboard.each_index do |index|
      if @turn_number == (index + 1)
        @gameboard[index] = @guess_value.to_s.delete('^0-9 " "') + '    ' + @guess_key
        puts @gameboard[index]
      else
        puts @gameboard[index]
      end
    end
    puts "-------------------------------------------------------------"
  end

  def play_mastermind
    puts 'Welcome to Mastermind'
    puts 'Please type "code creator" or "code guesser"'
    @player_role = gets.chomp.downcase
    assign_role
    play_round
  end

  def assign_role
    case @player_role
    when 'code creator'
      @player_creator = true
    when 'code guesser'
      @player_creator = false
    else
      puts 'please type code creator or code guesser'
      @player_role = gets.chomp.downcase
      assign_role
    end
  end

  def play_round
    @round_number += 1
    if @player_creator == true
      get_four_values
      @code_value = @four_values
      until @round_over == true
        play_computer_guess
      end
      @player_creator = false
      @turn_number = 0
      @round_over = false
      @potential_combinations = generate_potential_guesses
      game_over?
    elsif @player_creator == false
      get_computer_code
      until @round_over == true
        play_player_guess
      end
      @player_creator = true
      @turn_number = 0
      @round_over = false
      @potential_combinations = generate_potential_guesses
      game_over?
    end
  end

  def game_over?
    if @round_number == 1
      puts "The round is over. You have #{@player_score} points, I have #{@computer_score} points"
      play_round
    elsif @round_number == 2
      if @player_score > @computer_score
        puts "You're the winner with #{@player_score} points. I'm the loser with #{@computer_score} points"
        play_again?
      elsif @player_score < @computer_score
        puts "You're the loser with #{@player_score} points. I'm the winner with #{@computer_score} points"
        play_again?
      elsif @player_score == @computer_score
        puts "It's a tie! We both have #{@player_score} points"
        play_again?
      end
    end
  end

  def play_again?
    puts "Would you like to play again? (y/n)"
    @play_again_yes = gets.chomp.downcase
    if @play_again_yes == "y"
      @round_number = 0
      play_round
    elsif @play_again_yes == "n"
      puts "Farewell, thank you for playing!"
    else
      play_again?
    end
  end

  def play_player_guess
    @turn_number += 1
    @computer_score += 1
    get_player_guess
    winner?
  end

  def play_computer_guess
    @turn_number += 1
    @player_score += 1
    get_computer_guess
    winner?
  end

  def get_four_values
    puts "Please enter four values between 1 and 6. This will be your code"
    @four_values = gets.chomp.gsub(/\s+/, '').split('').map(&:to_i)
    if @four_values.difference([1, 2, 3, 4, 5, 6]).length != 0
      get_four_values
    elsif @four_values.length != 4
      get_four_values
    end
  end

  def get_computer_code
    generate_potential_guesses
    @code_value = @potential_combinations.sample
  end

  def get_player_guess
    puts "Please enter four values between 1 and 6. This will be your guess"
    @guess_value = gets.chomp.gsub(/\s+/, '').split('').map(&:to_i)
    if @guess_value.difference([1, 2, 3, 4, 5, 6]).length != 0
      get_player_guess
    elsif @guess_value.length != 4
      get_player_guess
    else
      get_guess_key
      puts_board
    end
  end

  def get_computer_guess
    if @turn_number == 1
      generate_potential_guesses
      @guess_value = [1, 1, 2, 2]
      get_guess_key
      puts_board
    else
      generate_new_combinations
      @guess_value = @new_combinations.min
      get_guess_key
      puts_board
      @potential_combinations = @new_combinations
      @new_combinations = []
    end
  end

  def generate_potential_guesses
    @potential_combinations = (1111..6666).to_a.map! { |x| x.digits.reverse }
    @potential_combinations.reject! do |x|
      x.include?(0) || x.include?(7) || x.include?(8) || x.include?(9)
    end
    @all_combinations = @potential_combinations
  end

  def winner?
    if @guess_value == @code_value
      @round_over = true
    elsif @turn_number == 12
      @round_over = true
    end
  end

  def get_guess_key
    @value_only = 0
    @value_location = 0
    for i in 1..6
      if @guess_value.count(i) >= @code_value.count(i)
        @value_only += @code_value.count(i)
      else @value_only += @guess_value.count(i)
      end
    end
    @guess_value.each_index do |index|
      if @guess_value[index] == @code_value[index]
        @value_location += 1
      end
    end
    @value_only -= @value_location
    @guess_key = "Correct value & location: #{@value_location}. Correct value only: #{@value_only}"
  end

  def get_combo_values
    @combo_value_only = 0
    @combo_value_location = 0
    for i in 1..6
      if @guess_value.count(i) >= @combo_value.count(i)
        @combo_value_only += @combo_value.count(i)
      else @combo_value_only += @guess_value.count(i)
      end
    end
    @guess_value.each_index do |index|
      if @guess_value[index] == @combo_value[index]
        @combo_value_location += 1
      end
    end
    @combo_value_only -= @combo_value_location
  end

  def get_possible_combos
    @potential_combinations.each do |combo|
      @combo_value = combo
      get_combo_values
      if (@combo_value_only == @value_only) && (@combo_value_location == @value_location)
        @new_combinations.push(combo)
      end
    end
  end

  def generate_new_combinations
    get_possible_combos
    @new_combinations = @new_combinations.uniq.sort!
  end
end

Mastermind.new.play_mastermind
