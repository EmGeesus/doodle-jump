extends CharacterBody2D

@export var JUMP_VELOCITY: float = -500.0
@export var velocity_component: Node
@onready var visual: Node2D = $visual
@export var boss_movement := false
@export var boss_move_speed := 220.0
@export var autojump := true


func _ready() -> void:
	set_color(ColorHandler.Type.RED)

func _physics_process(delta: float) -> void:
	var direction := Vector2(get_movement_vector().x, 0).normalized()
	if direction != Vector2.ZERO:
		velocity_component.accelerate_in_direction(direction, delta)
	else:
		velocity_component.decelerate(delta)
	if not is_on_floor():
		velocity_component.apply_gravity(delta)
	elif is_on_floor() and autojump:
		velocity_component.jump(JUMP_VELOCITY)
	velocity_component.move(self)
	handle_color_input()


func handle_color_input() -> void:
	if Input.is_action_just_pressed("color_red"):
		set_color(ColorHandler.Type.RED)
	elif Input.is_action_just_pressed("color_yellow"):
		set_color(ColorHandler.Type.YELLOW)
	elif Input.is_action_just_pressed("color_blue"):
		set_color(ColorHandler.Type.BLUE)


func set_color(new_color: int) -> void:
	ColorHandler.set_color(new_color)
	update_visual()
	
func get_movement_vector() -> Vector2:
	var x := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	return Vector2(x, 0)

func update_visual() -> void:
	print(ColorHandler.get_current_color())
	visual.modulate = ColorHandler.get_current_color()
func play_iframe_flash(duration: float) -> void:
	var elapsed := 0.0
	while elapsed < duration:
		_set_visual_alpha(0.3)
		await get_tree().create_timer(0.08).timeout
		_set_visual_alpha(1.0)
		await get_tree().create_timer(0.08).timeout
		elapsed += 0.16
	_set_visual_alpha(1.0)


func _set_visual_alpha(alpha: float) -> void:
	var color := visual.modulate
	color.a = alpha
	visual.modulate = color
