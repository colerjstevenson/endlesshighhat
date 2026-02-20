extends Control
class_name Opponent

var hand_size: int = 0

var hand: Array = []
var lives: int = 3

func _ready() -> void:
	#set visible to false until game starts
    $Panel.visible = true
    $NameLabel.text = western_name_maker()

    $Panel/Panel/Hand/Card1.show_back()
    $Panel/Panel/Hand/Card2.show_back()
    $Panel/Panel/Hand/Card3.show_back()

    




func western_name_maker() -> String:
    var first_names = ["Billy", "Jesse", "Doc", "Wyatt", "Butch", "Annie", "Calamity", "Django", "Clint", "Sundance"]
    var last_names = ["the Kid", "James", "Holliday", "Earp", "Cassidy", "Oakley", "Jane", "the Hutt", "Eastwood", "Kid"]
    var first_name = first_names[randi() % first_names.size()]
    var last_name = last_names[randi() % last_names.size()]
    return "%s %s" % [first_name, last_name]