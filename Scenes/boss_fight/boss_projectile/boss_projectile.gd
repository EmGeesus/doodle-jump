class_name BossProjectile
extends Area2D


signal returned_to_boss(projectile_color: int)
signal hit_player


@export var speed := 300.0
@export var reflected_speed_multiplier := 2.0
@export var lifetime := 10.0
@export var explosion_scene: PackedScene


var projectile_color := GameColor.Type.RED
var is_colored := false
var reflected := false
var direction := Vector2.DOWN
var age := 0.0

var boss_target: Node2D


@onready var visual: = $visual


func _ready() -> void:
	add_to_group("boss_projectile")

	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func setup_colored(color: int, target: Node2D) -> void:
	projectile_color = color
	boss_target = target
	is_colored = true

	visual.modulate = ColorHandler.translate(color)


func setup_neutral(target: Node2D) -> void:
	boss_target = target
	is_colored = false

	visual.modulate = Color.WHITE


func _physics_process(delta: float) -> void:
	age += delta

	if age >= lifetime:
		queue_free()
		return

	if reflected and is_instance_valid(boss_target):
		direction = global_position.direction_to(
			boss_target.global_position
		)

	global_position += direction * speed * delta

	rotation = direction.angle()


func _on_body_entered(body: Node) -> void:
	if reflected:
		return

	if not body.is_in_group("player"):
		return

	if is_colored:
		if ColorHandler.get_current_color() == ColorHandler.translate(projectile_color):
			reflect()
			return

	hit_player.emit()

	if body.has_method("take_hit"):
		body.call("take_hit")

	queue_free()


func reflect() -> void:
	reflected = true
	speed *= reflected_speed_multiplier

	if is_instance_valid(boss_target):
		direction = global_position.direction_to(
			boss_target.global_position
		)

	rotation = direction.angle()


func _on_area_entered(area: Area2D) -> void:
	if not reflected:
		return

	if not area.is_in_group("boss_hurtbox"):
		return

	returned_to_boss.emit(projectile_color)
	_explode()


func _explode() -> void:
	if explosion_scene != null:
		var explosion := explosion_scene.instantiate()

		get_tree().current_scene.add_child(explosion)
		explosion.global_position = global_position

	queue_free()
