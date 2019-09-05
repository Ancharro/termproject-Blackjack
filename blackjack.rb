#initialize and restrict user input
USER_INPUT_POSITIVE = 'y'
USER_INPUT_NEGATIVE = 'n'
POSSIBLE_USER_INPUTS = [USER_INPUT_POSITIVE, USER_INPUT_NEGATIVE]

class Blackjack
  #referenced a deck from from another project on Github
  DECK = [
    'Ah', '2h', '3h', '4h', '5h', '6h', '7h', '8h', '9h', '10h', 'Jh', 'Qh', 'Kh','Ad', '2d', '3d', '4d',
    '5d', '6d', '7d', '8d', '9d', '10d', 'Jd', 'Qd', 'Kd', 'As', '2s', '3s', '4s', '5s', '6s', '7s', '8s', '9s',
    '10s', 'Js', 'Qs', 'Ks', 'Ac', '2c', '3c', '4c', '5c', '6c', '7c', '8c', '9c', '10c', 'Jc', 'Qc', 'Kc'
  ]

  GOAL = 21
  # The score when dealer stops picking up cards
  DEALER_SCORE_THRESHOLD = 17

  attr_accessor :hand_player_arr, :hand_dealer_arr

  def initialize
    self.hand_player_arr = []
    self.hand_dealer_arr = []

    2.times do
      add_card(:player)
      add_card(:dealer)
    end
  end

  # Returns either winner (currently it's :player or :dealer), or nil in case of draw
  def start_game
    print_hand(:player)
    print_hand(:dealer)

    if calculate_total(:dealer) == GOAL
      print_winner(:dealer)
      return :dealer
    elsif calculate_total(:player) == GOAL
      print_winner(:player)
      return :player
    end

    puts "To hit enter #{USER_INPUT_POSITIVE}, to stay this hand, type #{USER_INPUT_NEGATIVE}"

    # Player can get cards until he bust or have 21 points
    loop do
      player_input = validated_user_input

      break if player_input == USER_INPUT_NEGATIVE

      add_card(:player)

      print_hand(:player)

      player_total = calculate_total(:player)

      # if player has 21 points and dealer doesn't draw a 21 player wins
      # if player has more that 21 points, he busts.
      if player_total > GOAL
        puts "Player busted,"
        return :dealer
      elsif player_total == GOAL
        print_winner(:player)
        return :player
      end
    end

    get_dealer_cards

    print_hand(:player)
    print_hand(:dealer)

    finish_the_game
  end

  def print_hand(player_type)
    puts "#{player_type.capitalize} hand is: #{player_hand_by_type(player_type).join(', ')}"
    puts "Score: #{calculate_total(player_type)}"
  end

  def print_winner(player_type)
    puts "#{player_type} has won the game!"
  end

  private

  def validated_user_input
    loop do
      player_input = get_input_from_console
      if POSSIBLE_USER_INPUTS.include? player_input
        return player_input
      else
        puts "Please enter either #{POSSIBLE_USER_INPUTS.join(' or ')}"
      end
    end
  end

  def get_dealer_cards
    while calculate_total(:dealer) < DEALER_SCORE_THRESHOLD
      add_card(:dealer)
    end
  end

  def add_card(player_type)
    player_hand_by_type(player_type) << pick_a_card_from_deck
  end

  def pick_a_card_from_deck
    DECK.sample
  end
#referenced information about send function as I found logical errors.
  def player_hand_by_type(player_type)
    send("hand_#{player_type}_arr")
  end

  def finish_the_game
    # Save values into variables not to calculate total each time we need it below
    player_total = calculate_total(:player)
    dealer_total = calculate_total(:dealer)

    if dealer_total > GOAL
      print_winner(:player)
      :player
    elsif dealer_total < player_total
      print_winner(:player)
      :player
    elsif dealer_total == player_total
      print_winner(:nobody)
    else
      print_winner(:dealer)
      :dealer
    end
  end

  def get_input_from_console
    gets.strip
  end

  def calculate_total(player_type)
    total = 0
    ace_cnt = 0
    player_hand_by_type(player_type).each do |card|
      case card.slice(0)
      when "A"
        total += 11
        #for each ace that occurs there is a counter that keeps track, if the number of aces is > 1 then the program will subtract 10 from the total
        ace_cnt += 1
      when "J"
        total += 10
      when "Q"
        total += 10
      when "K"
        total += 10
      else
        total += card.to_i
      end
    end

    while ace_cnt > 0
      break if total <= GOAL

      total -= 10
      ace_cnt -= 1
    end
    total
  end
end

def main
  score_hash = { wins: 0, losses: 0, draws: 0 }

  puts "Welcome!!!"

  loop do
    game = Blackjack.new
    result = game.start_game

    case result
    when :dealer
      score_hash[:losses] += 1
    when :player
      score_hash[:wins] += 1
    else
      score_hash[:draws] += 1
    end

    puts "If you want to play again, type #{USER_INPUT_POSITIVE}, enter any other input to end the game and report wins, losses, and draws."
    player_input = gets.strip
    break unless player_input == USER_INPUT_POSITIVE
  end

  puts "Thank you for playing. Your results are being saved to file 'blackjack_results.txt'"
#REFERENCED RUBYDOCS FOR MAP FUNCTION
  File.open("./blackjack_results.txt", 'a') do |file|
    file.puts(score_hash.map { |key, value| "#{key}: #{value}" }.join(', ') + ';')
  end
  score_hash
end
