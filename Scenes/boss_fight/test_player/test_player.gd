extends CharacterBody2D

signal color_changed(new_color: int)
@export var move_speed = 300.0
@export var jump_velocity = -400.0
@export var autojump = false;

@onready var visual: Node2D = $visual

var current_color := GameColor.Type.RED

func _ready() -> void:
	_update_visual()

func _physics_process(_delta: float) -> void:
	_handle_movement()
	_handle_color_input()
	
func _handle_movement() -> void:
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * move_speed
	velocity.y = 0.0
	if not is_on_floor():
		velocity.y = 200
	move_and_slide()

func _handle_color_input() -> void:
	if Input.is_action_just_pressed("color_red"):
		set_color(GameColor.Type.RED)
	elif Input.is_action_just_pressed("color_yellow"):
		set_color(GameColor.Type.YELLOW)
	elif Input.is_action_just_pressed("color_blue"):
		set_color(GameColor.Type.BLUE)

func set_color(new_color: int) -> void:
	current_color = new_color
	_update_visual()
	color_changed.emit(current_color)

func get_current_color() -> int:
	return current_color
