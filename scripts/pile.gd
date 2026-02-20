extends Control
class_name Pile

var cards = []

func _ready():
	cards.clear()
	$card.visible = false

func setup():
	pass


func add_card(card):
	cards.append(card)
	$card.visible = true
	$card
