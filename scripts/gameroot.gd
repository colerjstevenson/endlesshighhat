extends Control

var player_hand: Hand = null

func _ready() -> void:
	# Get reference to the player's hand from the scene
	player_hand = $BottomArea/Hand
	
	# Store reference in Game singleton
	Game.player_hand = player_hand
	
	# Initialize and start the game
	start_game()

func start_game() -> void:
	# Clear any placeholder cards from the scene
	player_hand.clear_hand()
	
	# Shuffle the deck (using global Deck singleton)
	Deck.shuffle_deck()
	print("Deck has %d cards" % Deck.cards.size())
	
	# Deal initial cards to player (5 cards)
	deal_cards_to_player(5)
	print("Player hand has %d cards" % player_hand.cards.size())

func deal_cards_to_player(num_cards: int) -> void:
	"""Deal a specified number of cards to the player's hand"""
	for i in range(num_cards):
		var card = Deck.draw_card()
		if card:
			print("Dealing card: %s of %s" % [card.rank, card.suit])
			player_hand.add_card(card)
		else:
			print("Failed to draw card!")
