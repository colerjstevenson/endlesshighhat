extends Control


func _ready() -> void:
	# Initialize player hand and opponents
	Game.player_hand = Hand.new()
	add_child(Game.player_hand)
	
	var opponent1 = Opponent.new()
	add_child(opponent1)
	Game.opponents.append(opponent1)
	
	var opponent2 = Opponent.new()
	add_child(opponent2)
	Game.opponents.append(opponent2)
