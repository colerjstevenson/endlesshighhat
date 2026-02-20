extends Control
class_name Opponent

var hand_size: int = 0

var hand: Array = []
var lives: int = 3

func setup():
    hand.clear()
    lives = 3
    hand_size = 3
    $Name.text = western_name_maker()

    #add cards to hand
    for i in range(hand_size):
        var card = Deck.draw_card()
        hand.append(card)
        $Hand.add_child(card)


# arrange cards nicely in hand
# based on hand size and card size
func space_hand():
    for i in range(hand.size()):
        var card = hand[i]
        card.rect_position = Vector2(10 + i * 110, 10)  # Adjust spacing as needed
        


    




func western_name_maker() -> String:
    var first_names = ["Billy", "Jesse", "Doc", "Wyatt", "Butch", "Annie", "Calamity", "Django", "Clint", "Sundance"]
    var last_names = ["the Kid", "James", "Holliday", "Earp", "Cassidy", "Oakley", "Jane", "the Hutt", "Eastwood", "Kid"]
    var first_name = first_names[randi() % first_names.size()]
    var last_name = last_names[randi() % last_names.size()]
    return "%s %s" % [first_name, last_name]