extends Node2D


@export var chunk_length: float = 2000
@export var endless: bool = false
@export var platform_spacing: float = 50
@export var spawn_platforms: bool = true

const PLATFORM = preload("uid://l5gj7xbh5ldo")
var spawn_count = 0


func _ready():
	if spawn_platforms:
		create_platform_chunk(spawn_count * chunk_length + 360)


func create_platform_chunk(start_height:float):
	var end_height = (start_height - chunk_length)
	var current_height = start_height
	var platform_holder = Node2D.new()
	platform_holder.name = "plaform chunk"
	add_child(platform_holder)
	while(current_height > end_height):
		var platform_instance = PLATFORM.instantiate()
		platform_instance.position = Vector2(randf_range(0,640),current_height + randf_range(-20,20))
		current_height -= platform_spacing
		platform_holder.add_child(platform_instance)
		platform_instance.set_color(ColorHandler.get_random_color())
		if platform_instance.get_color() != ColorHandler.get_current_color():
			platform_instance.disable()
	
	return platform_holder
		
