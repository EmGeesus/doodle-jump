extends Area2D

signal returned_to_boss(projectile_color: int)
signal hit_player

@export var speed := 50.0
@export var lifetime := 8.

@onready var visual: Node2D = $visual

var projectile_color := GameColor.Type.RED
var direction := Vector2.DOWN

var reflected := false
var age := 0.0

@export var boss_target: Node2D


func _ready() -> void:
	add_to_group("boss_projectile")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	_update_visual()

func setup(new_color: int, target: Node2D) -> void:
	projectile_color = new_color
	boss_target = target
	if is_node_ready():
		_update_visual()

func _physics_process(delta: float) -> void:
	print(age)
	age += delta

	if age >= lifetime:
		queue_free()
		return

	if reflected and is_instance_valid(boss_target):
		direction = global_position.direction_to(
			boss_target.global_position
		)
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if reflected:
		return
	if not body.has_method("get_current_color"):
		return
	var player_color: int = body.call("get_current_color")
	if player_color == projectile_color:
		reflect()
	else:
		hit_player.emit()

		if body.has_method("take_hit"):
			body.call("take_hit")

		queue_free()
func reflect() -> void:
	reflected = true
	speed *= 1.35

	if is_instance_valid(boss_target):
		direction = global_position.direction_to(
			boss_target.global_position
		)


func _on_area_entered(area: Area2D) -> void:
	if not reflected:
		return

	if area.is_in_group("boss_hurtbox"):
		returned_to_boss.emit(projectile_color)
		queue_free()


func _update_visual() -> void:
	visual.modulate = GameColor.visual_color(projectile_color)
