extends Node

@export var max_speed: float = 200.0
@export var acceleration: float = 5.0
@export var terminal_velocity: float = 900.0

var velocity = Vector2.ZERO
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _smooth(rate: float, delta: float) -> float:
	return 1.0 - exp(-rate * delta)

func apply_gravity(delta: float):
	var rate := gravity / terminal_velocity
	velocity.y = lerp(velocity.y, terminal_velocity, _smooth(rate, delta))

func jump(speed: float):
	velocity.y = speed

func accelerate_in_direction(direction: Vector2, delta: float):
	var desired_x := direction.x * max_speed
	velocity.x = lerp(velocity.x, desired_x, _smooth(acceleration, delta))

func decelerate(delta: float):
	accelerate_in_direction(Vector2.ZERO, delta)

func move(character_body: CharacterBody2D):
	character_body.velocity = velocity
	character_body.move_and_slide()
	velocity = character_body.velocity
