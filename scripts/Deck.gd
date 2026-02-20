extends Node

var discarded_cards: Array = []

var cards: Array = []

var suts = ["clubs", "diamonds", "hearts", "spades"]
var ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king", "ace"]

func _ready() -> void:
	# Create a standard deck of 52 cards
	print("Creating deck...")
	for suit in suts:
		for rank in ranks:
			var card_scene = preload("res://scenes/Card.tscn")
			var card_instance = card_scene.instantiate() as Card
			card_instance.setup(rank, suit)
			cards.append(card_instance)
	print("Deck created with %d cards" % cards.size())



func shuffle_deck() -> void:
	# Shuffle the deck using Fisher-Yates algorithm
	var n = cards.size()
	for i in range(n - 1, 0, -1):
		var j = randi() % (i + 1)
		var temp = cards[i]
		cards[i] = cards[j]
		cards[j] = temp

func draw_card() -> Card:
	# Draw a card from the top of the deck
	if cards.size() > 0:
		return cards.pop_back() as Card
	else:
		cards = discarded_cards.duplicate()
		discarded_cards.clear()
		shuffle_deck()

		return cards.pop_back() as Card


func discard_card(card: Card) -> void:
	# Add a card to the discard pile
	discarded_cards.append(card)
