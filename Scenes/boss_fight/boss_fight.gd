class_name BossFight
extends Node2D


signal boss_defeated
signal player_hit


@export var projectile_scene: PackedScene

@export var max_health := 12
@export var colored_bullet_chance := 0.25

@export var phase_1_fire_rate := 1.0
@export var phase_2_fire_rate := 0.7
@export var phase_3_fire_rate := 0.45


@onready var boss: Area2D = $Boss
@onready var spawn_points: Array[Node] = $Spawns.get_children()
@onready var shot_timer: Timer = $ShotTimer


var health: int
var active_spawn_count := 2


func _ready() -> void:
	boss.add_to_group("boss_hurtbox")

	shot_timer.timeout.connect(_shoot)

	start_fight()


func start_fight() -> void:
	health = max_health
	_update_phase()
	shot_timer.start()


func _shoot() -> void:
	if spawn_points.is_empty():
		return

	var spawn_point := _get_random_spawn_point()
	var projectile: = projectile_scene.instantiate() as BossProjectile

	add_child(projectile)

	projectile.global_position = spawn_point.global_position
	projectile.returned_to_boss.connect(_on_projectile_returned)
	projectile.hit_player.connect(_on_player_hit)

	if randf() <= colored_bullet_chance:
		var color := randi_range(
			GameColor.Type.RED,
			GameColor.Type.BLUE
		)

		projectile.setup_colored(color, boss)
	else:
		projectile.setup_neutral(boss)


func _get_random_spawn_point() -> Node2D:
	var amount := mini(active_spawn_count, spawn_points.size())
	var index := randi_range(0, amount - 1)

	return spawn_points[index] as Node2D


func _on_projectile_returned(_color: int) -> void:
	health -= 1

	print("Boss HP: ", health)

	if health <= 0:
		shot_timer.stop()
		boss_defeated.emit()
		return

	_update_phase()


func _on_player_hit() -> void:
	player_hit.emit()


func _update_phase() -> void:
	var health_percent := float(health) / float(max_health)

	if health_percent > 0.66:
		active_spawn_count = 2
		shot_timer.wait_time = phase_1_fire_rate

	elif health_percent > 0.33:
		active_spawn_count = 4
		shot_timer.wait_time = phase_2_fire_rate

	else:
		active_spawn_count = spawn_points.size()
		shot_timer.wait_time = phase_3_fire_rate
