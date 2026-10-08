extends Node2D

@export var collision_shape_2d: CollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D


@export var color: Color = Color.WHITE

func _ready():
	ColorHandler.color_changed.connect(_on_color_changed)



func set_color(value):
	value = ColorHandler.translate(value)
	animated_sprite_2d.modulate = value
	color = value

func _on_color_changed():
	if ColorHandler.get_current_color() == color:
		enable()
	else:
		disable()
		

func get_color():
	return color

func disable():
	collision_shape_2d.disabled = true
	var temp_color = color
	temp_color.a = .3
	animated_sprite_2d.modulate = temp_color

func enable():
	collision_shape_2d.disabled = false
	color.a = 1
	animated_sprite_2d.modulate = color
	
