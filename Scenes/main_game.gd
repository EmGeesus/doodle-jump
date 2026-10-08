extends Node2D


@export var chunk_length: float = 2000
@export var endless: bool = false
@export var platform_spacing: float = 50
@export var spawn_platforms: bool = true
@export var goal_height = -10000
@onready var player = $Player
@onready var player_speaking = $"CanvasLayer/Player speaking"

const PLATFORM = preload("uid://l5gj7xbh5ldo")
var spawn_count = 0
var current_chunk: Node2D
var previous_chunk: Node2D

func _ready():
	player_speaking.play_animation_with_text(["I gotta get out of here, and fast, it's a prison break!", "The walls of this place loop? Crazy!"])
	if spawn_platforms:
		current_chunk = create_platform_chunk((spawn_count * chunk_length * -1) + 360)

func _process(delta):
	if player:
		if player.position.y <= (spawn_count * chunk_length * -1) + 800:
			player.level_up()
			create_new_chunk()
		if player.position.y > goal_height:
			win()


func speak(input:Array):
	player_speaking.play_animation_with_text(input)

func win():
	pass

func get_goal_height():
	return goal_height

func create_new_chunk():
	if previous_chunk:
		previous_chunk.queue_free()
	previous_chunk = current_chunk
	current_chunk = create_platform_chunk((spawn_count * chunk_length * -1) + 360)

func create_platform_chunk(start_height:float):
	var end_height = (start_height - chunk_length)
	var current_height = start_height
	var platform_holder = Node2D.new()
	platform_holder.name = "plaform chunk" + str(spawn_count)
	add_child(platform_holder)
	while(current_height > end_height):
		var platform_instance = PLATFORM.instantiate()
		platform_instance.position = Vector2(randf_range(0,640),current_height + randf_range(-20,20))
		current_height -= platform_spacing
		platform_holder.add_child(platform_instance)
		if player:
			platform_instance.set_color(ColorHandler.get_random_color(player.get_level()))
		else:
			platform_instance.set_color(ColorHandler.get_random_color())
		if platform_instance.get_color() != ColorHandler.get_current_color():
			platform_instance.disable()
	spawn_count += 1
	return platform_holder
		
