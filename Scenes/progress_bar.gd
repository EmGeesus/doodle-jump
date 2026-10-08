extends ProgressBar




var player: CharacterBody2D
var goal_height

func _ready():
	ColorHandler.color_changed.connect(_on_color_change)
	player = get_tree().get_first_node_in_group("player")
	get_theme_stylebox("fill").set("bg_color", ColorHandler.get_current_color())
	goal_height = get_parent().get_parent().get_goal_height()
	max_value = goal_height * -1
	

func _process(delta):
	if player:
		if player.position.y > 0:
			value = 0
		else:
			value = player.position.y * -1


func _on_color_change():
	get_theme_stylebox("fill").set("bg_color", ColorHandler.get_current_color())
