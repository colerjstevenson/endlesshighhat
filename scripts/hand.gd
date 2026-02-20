extends Control
class_name Hand

# Players Hand of cards
var cards: Array = []
var selected_cards: Array = []
var max_selected: int = 3  # Maximum number of cards that can be selected at once

# Card arrangement settings
var card_spacing: float = 50.0 # Horizontal spacing between cards
var arc_height: float = 5.0  # How much cards arc upward in the middle
var selected_offset: float = -40.0  # How much to pop up selected cards
var animation_speed: float = 0.15  # Duration for card movement animations

# Drag and drop variables
var dragged_card: Card = null
var drag_start_pos: Vector2
var drag_offset: Vector2
var original_card_index: int = -1
var drag_threshold: float = 10.0  # Pixels before we consider it a drag
var is_dragging: bool = false  # Track if we've actually started dragging

# Track active tweens for each card
var card_tweens: Dictionary = {}

func _ready() -> void:
	# Find all card children and set them up
	refresh_cards()
	layout_hand()
	
	# Connect to card signals
	for card in cards:
		if card and card.has_signal("card_selected"):
			card.card_selected.connect(_on_card_selected)
		if card and card.has_signal("card_deselected"):
			card.card_deselected.connect(_on_card_deselected)

func refresh_cards():
	"""Find all card children in the scene"""
	cards.clear()
	for child in get_children():
		if child is Card:
			cards.append(child)
			# Connect input signal if not already connected
			if not child.gui_input.is_connected(_on_card_gui_input):
				child.gui_input.connect(_on_card_gui_input.bind(child))
			# Connect card signals if not already connected
			if child.has_signal("card_selected") and not child.card_selected.is_connected(_on_card_selected):
				child.card_selected.connect(_on_card_selected)
			if child.has_signal("card_deselected") and not child.card_deselected.is_connected(_on_card_deselected):
				child.card_deselected.connect(_on_card_deselected)

func clear_hand():
	"""Remove all cards from the hand"""
	for card in cards.duplicate():
		remove_card(card)
	cards.clear()
	selected_cards.clear()
	card_tweens.clear()

func layout_hand(animate: bool = false):
	"""Arrange cards in hand visually with a nice arc"""
	var num_cards = cards.size()
	if num_cards == 0:
		return
	
	# Calculate the starting position to center the hand
	var total_width = (num_cards - 1) * card_spacing
	var start_x = (size.x - total_width) / 2.0
	
	for i in range(num_cards):
		var card = cards[i]
		if not card:
			continue
		
		# Calculate position with arc
		var x_pos = start_x + i * card_spacing
		var arc_progress = float(i) / max(num_cards - 1, 1)  # 0 to 1
		var arc_factor = sin(arc_progress * PI)  # Creates arc shape
		var y_pos = size.y / 2.0 - arc_factor * arc_height
		
		# Add selection offset if card is selected
		if card in selected_cards:
			y_pos += selected_offset
		
		var target_pos = Vector2(x_pos, y_pos)
		
		if animate:
			animate_card_to_position(card, target_pos, i)
		else:
			card.position = target_pos
		
		# Set z-index so cards overlap nicely
		card.z_index = i

func animate_card_to_position(card: Card, target_pos: Vector2, target_z_index: int):
	"""Smoothly animate a card to a target position"""
	# Cancel existing tween for this card if any
	if card in card_tweens and card_tweens[card]:
		card_tweens[card].kill()
	
	# Create and start new tween
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(card, "position", target_pos, animation_speed)
	card_tweens[card] = tween
	card.z_index = target_z_index

func _on_card_gui_input(event: InputEvent, card: Card):
	"""Handle mouse input on cards for dragging"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Consume input initially to prevent immediate selection
				get_viewport().set_input_as_handled()
				
				# Prepare for potential drag
				dragged_card = card
				original_card_index = cards.find(card)
				drag_start_pos = card.position
				drag_offset = card.get_local_mouse_position()
				is_dragging = false  # Not dragging yet, just clicked
			elif dragged_card == card:
				# Mouse released
				if is_dragging:
					# Was dragging, finalize the reorder
					dragged_card = null
					reorder_cards_by_position(card)
					layout_hand(true)
					is_dragging = false
					# Consume input so card doesn't toggle selection on drag release
					get_viewport().set_input_as_handled()
				else:
					# Was just a click, let the card handle selection now
					dragged_card = null
					card.set_selected(!card.is_selected)

func _process(_delta):
	"""Handle card dragging"""
	if dragged_card and not is_dragging:
		# Check if mouse has moved past threshold to start drag
		var mouse_pos = get_local_mouse_position()
		var distance_moved = dragged_card.position.distance_to(mouse_pos - drag_offset)
		if distance_moved > drag_threshold:
			is_dragging = true
			dragged_card.z_index = 1000  # Bring to front once dragging starts
	
	if dragged_card and is_dragging:
		# Move card with mouse
		var mouse_pos = get_local_mouse_position()
		dragged_card.position = mouse_pos - drag_offset
		
		# Calculate where the card would be inserted and show preview
		var preview_index = calculate_insertion_index(dragged_card.position.x)
		layout_hand_with_gap(preview_index)

func calculate_insertion_index(drag_x: float) -> int:
	"""Calculate where the dragged card should be inserted based on x position"""
	var num_cards = cards.size()
	if num_cards <= 1:
		return 0
	
	# Calculate ideal x positions as if all cards were laid out
	var total_width = (num_cards - 1) * card_spacing
	var start_x = (size.x - total_width) / 2.0
	
	# Find which slot the dragged card is closest to
	var closest_index = 0
	var min_distance = abs(drag_x - start_x)
	
	for i in range(num_cards):
		var slot_x = start_x + i * card_spacing
		var distance = abs(drag_x - slot_x)
		if distance < min_distance:
			min_distance = distance
			closest_index = i
	
	# If card is past the last slot, it goes at the end
	var last_slot_x = start_x + (num_cards - 1) * card_spacing
	if drag_x > last_slot_x + card_spacing / 2.0:
		closest_index = num_cards
	
	return closest_index

func layout_hand_with_gap(gap_index: int):
	"""Arrange cards with a gap at the specified index to show where dragged card will go"""
	var num_cards = cards.size()
	if num_cards == 0:
		return
	
	# Calculate the starting position to center the hand
	var total_width = (num_cards - 1) * card_spacing
	var start_x = (size.x - total_width) / 2.0
	
	# Track the original position of each card for arc calculation
	var original_index = 0
	
	for i in range(num_cards):
		var card = cards[i]
		if card == dragged_card:
			original_index += 1
			continue  # Skip the dragged card
		
		# Calculate visual position accounting for the gap
		var visual_position = original_index
		if visual_position >= gap_index:
			visual_position += 1  # Shift right to make room for gap
		
		# Calculate position with arc based on original card index
		var x_pos = start_x + visual_position * card_spacing
		var arc_progress = float(original_index) / max(num_cards - 1, 1)
		var arc_factor = sin(arc_progress * PI)
		var y_pos = size.y / 2.0 - arc_factor * arc_height
		
		# Add selection offset if card is selected
		if card in selected_cards:
			y_pos += selected_offset
		
		var target_pos = Vector2(x_pos, y_pos)
		
		# Use faster animation during dragging for responsive feel
		animate_card_to_position(card, target_pos, visual_position)
		
		original_index += 1

func reorder_cards_by_position(moved_card: Card):
	"""Reorder the card array based on the dragged card's position"""
	if original_card_index < 0 or original_card_index >= cards.size():
		return
	
	# Use the same calculation as the preview
	var new_index = calculate_insertion_index(moved_card.position.x)
	
	# Remove from old position
	cards.remove_at(original_card_index)
	
	# Adjust new_index if we removed an element before it
	if new_index > original_card_index:
		new_index -= 1
	
	# Clamp to valid range after removal
	new_index = clamp(new_index, 0, cards.size())
	
	# Insert at new position
	cards.insert(new_index, moved_card)
	
	original_card_index = -1

func _on_card_selected(card: Card):
	"""Handle card selection"""
	# If we've reached the limit, prevent the selection
	if selected_cards.size() >= max_selected:
		# Revert the card's selection state without triggering signals
		card.is_selected = false
		return
	
	if card not in selected_cards:
		selected_cards.append(card)
	
	layout_hand(true)

func _on_card_deselected(card: Card):
	"""Handle card deselection"""
	if card in selected_cards:
		selected_cards.erase(card)
	
	layout_hand(true)

func get_selected_cards() -> Array:
	"""Return array of currently selected cards"""
	return selected_cards.duplicate()

func clear_selection():
	"""Deselect all cards"""
	for card in selected_cards.duplicate():
		card.set_selected(false)
	selected_cards.clear()
	layout_hand(true)

func add_card(card: Card):
	"""Add a new card to the hand"""
	print("Adding card to hand: ", card.rank if card else "null", " of ", card.suit if card else "null")
	add_child(card)
	cards.append(card)
	
	# Connect signals if not already connected
	if card.has_signal("card_selected") and not card.card_selected.is_connected(_on_card_selected):
		card.card_selected.connect(_on_card_selected)
	if card.has_signal("card_deselected") and not card.card_deselected.is_connected(_on_card_deselected):
		card.card_deselected.connect(_on_card_deselected)
	if not card.gui_input.is_connected(_on_card_gui_input):
		card.gui_input.connect(_on_card_gui_input.bind(card))
	
	print("Card added successfully, total cards in hand: ", cards.size())
	layout_hand(true)

func remove_card(card: Card):
	"""Remove a card from the hand"""
	# Clean up any active tweens for this card
	if card in card_tweens and card_tweens[card]:
		card_tweens[card].kill()
		card_tweens.erase(card)
	
	if card in cards:
		cards.erase(card)
	if card in selected_cards:
		selected_cards.erase(card)
	card.queue_free()
	layout_hand(true)
