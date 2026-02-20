extends Control
class_name Hand

# Players Hand of cards
var hand: Array = []
var hand_size: int = 0

func _ready() -> void:
	# Initialize hand with empty card slots
	hand_size = 5
	for i in range(hand_size):
		hand.append(null)  # Placeholder for card instances
