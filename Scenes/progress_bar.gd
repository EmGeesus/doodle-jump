extends ProgressBar




var player: CharacterBody2D
var goal_height

func _ready():
	player = get_tree().get_first_node_in_group("player")
	goal_height = get_parent().get_parent().get_goal_height()
	max_value = goal_height * -1
	


func _process(delta):
	if player:
		if player.position.y > 0:
			value = 0
		else:
			value = player.position.y * -1
