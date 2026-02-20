extends Control
class_name Card

# Card properties
var rank: String
var suit: String
var is_selected: bool = false
var is_flipped: bool = false

# Cached textures
var card_face_texture: Texture2D
var card_back_texture: Texture2D


const RANK_VALUES = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king", "ace"]
const SUITS = ["clubs", "diamonds", "hearts", "spades"]

# Signals
signal card_selected(card: Card)
signal card_deselected(card: Card)


func _ready() -> void:
	gui_input.connect(_on_gui_input)


func setup(r: String, s: String, f:bool=false) -> void:
	"""Initialize card with rank and suit and preload textures"""
	rank = r.to_lower()
	suit = s.to_lower()
	is_flipped = f
	
	# Load card face texture from correct path
	var suit_folder = suit.capitalize()
	card_face_texture = load("res://assets/Cards/%s/%s_of_%s.png" % [suit_folder, rank, suit])
	$front.texture = card_face_texture
	
	# Load card back texture
	card_back_texture = load("res://assets/Cards/Decks/deck_1_blue.png")
	$back.texture = card_back_texture
	
	# Show the appropriate side
	if is_flipped:
		show_back()
	else:
		show_front()





func set_selected(selected: bool) -> void:
	"""Set card selected state"""
	if is_selected == selected:
		return  # No change
	
	is_selected = selected
	
	# Emit signals so the hand can handle positioning
	if selected:
		emit_signal("card_selected", self)
	else:
		emit_signal("card_deselected", self)

func get_value() -> int:
	"""Get the numeric value of the card for scoring"""
	if rank.is_valid_int():
		return int(rank)
	elif rank == "ace":
		return 11
	else:
		return 10



func _on_gui_input(event: InputEvent) -> void:
	"""Handle mouse input on the card"""
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			set_selected(!is_selected)


func show_front():
	$front.visible = true
	$back.visible = false

func show_back():
	$front.visible = false
	$back.visible = true



func flip():
	if is_flipped:
		show_front()
	else:
		show_back()
	is_flipped = !is_flipped
