#reference a youtube video about making a blackjack app in ruby and Rspec was used.
#found that this was a better fit than minitest for testing some cases.

require './blackjack'

RSpec.describe Blackjack do
  let(:initial_player_hand) { ['10s', '9d'] }
  let(:initial_dealer_hand) { ['2s', 'Kd'] }
  let(:game) do
    game = Blackjack.new
    game.hand_player_arr = initial_player_hand
    game.hand_dealer_arr = initial_dealer_hand
    game
  end

  it 'gives victory to player immediately if he gets 21 with the third card' do
    expect_any_instance_of(Blackjack).to receive(:validated_user_input) { 'y' }
    expect_any_instance_of(Blackjack).to receive(:pick_a_card_from_deck).exactly(4).times.and_call_original
    expect_any_instance_of(Blackjack).to receive(:pick_a_card_from_deck) { '2h' }

    expect(game.start_game).to eq(:player)
  end

  context 'player has 21 points in initial hand' do
    let(:initial_player_hand) { ['Ah', 'Kd'] }

    it('gives victory to player') { expect(game.start_game).to eq(:player) }

    context 'dealer has 21 points in initial hand' do
      let(:initial_dealer_hand) { ['As', '10c'] }

      it('gives victory to dealer') { expect(game.start_game).to eq(:dealer) }
    end
  end

  it 'makes draw if players have equal amount of points' do
    expect_any_instance_of(Blackjack).to receive(:validated_user_input) { 'n' }
    expect_any_instance_of(Blackjack).to receive(:pick_a_card_from_deck).exactly(4).times.and_call_original
    expect_any_instance_of(Blackjack).to receive(:pick_a_card_from_deck) { '7h' }

    expect(game.start_game).to eq(nil)
  end
end
