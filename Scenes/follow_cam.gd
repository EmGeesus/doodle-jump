extends Camera2D



var player : CharacterBody2D
var max_height = 150

func _ready():
	position.x = 320
	player = get_tree().get_first_node_in_group("player")

func _process(delta):
	if player:
		if player.position.y < 160:
			if player.position.y < max_height:
				max_height = player.position.y
		
		position.y = max_height + 30
		if player.position.y > position.y + 230:
			player.hurt()
