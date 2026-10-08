class_name BossFight
extends Node2D


signal boss_defeated
signal player_hit


enum Pattern {
	RAIN,
	WALL,
	COLOR_STREAM
}


@export var projectile_scene: PackedScene
@export var max_health := 12
@export var player_max_health := 5
@export var colored_bullet_chance := 0.3
@onready var player: CharacterBody2D = $Player
@export var player_invulnerability := 0.6
var player_invulnerable := false
@export var hit_stun_length := 0.25
@export var pattern_break := 0.5

@onready var boss_theme: AudioStreamPlayer = $BossTheme
@onready var boss_health_bar: ProgressBar = $UI/BossUI/Bars/BossHealthBar
@onready var player_health_bar: ProgressBar = $UI/PlayerUI/VBoxContainer/PlayerHealthBar

@onready var boss: Area2D = $Boss
@onready var spawn_points: Array[Node] = $Spawns.get_children()
@export var boss_shake_amount := 4.0

@onready var boss_sprite: Sprite2D = $Boss/Sprite2D
@onready var boss_hit: AudioStreamPlayer = $BossHit

var boss_stunned := false

var health: int
var active_spawn_count := 3
var fight_active := false
var hit_stun_time := 0.0
var last_pattern := -1
var player_health: int
var player_dead := false

func _ready() -> void:
	boss.add_to_group("boss_hurtbox")
	start_fight()


func _process(delta: float) -> void:
	hit_stun_time = maxf(hit_stun_time - delta, 0.0)


func start_fight() -> void:
	health = max_health
	player_health = player_max_health
	player_dead = false
	
	boss_health_bar.max_value = max_health
	boss_health_bar.value = health
	
	player_health_bar.max_value = player_max_health
	player_health_bar.value = player_health
	fight_active = true
	_update_phase()
	_attack_loop()
	boss_theme.play()


func _attack_loop() -> void:
	while fight_active:
		var health_percent := float(health) / float(max_health)
		var pattern: int

		if health_percent > 0.66:
			pattern = _choose_pattern(1)

			if pattern == Pattern.RAIN:
				await _rain(6, 0.32)
			else:
				await _color_stream(3, 0.5)

		elif health_percent > 0.33:
			pattern = _choose_pattern(2)

			if pattern == Pattern.RAIN:
				await _rain(9, 0.24)
			elif pattern == Pattern.WALL:
				await _wall_with_gap()
			else:
				await _color_stream(4, 0.38)

		else:
			pattern = _choose_pattern(2)

			if pattern == Pattern.RAIN:
				await _rain(14, 0.16)
			elif pattern == Pattern.WALL:
				await _wall_with_gap()
				await _wait(0.25)
				await _wall_with_gap()
			else:
				await _color_stream(6, 0.25)

		await _wait(pattern_break)


func _choose_pattern(highest_pattern: int) -> int:
	var pattern := randi_range(0, highest_pattern)

	if pattern == last_pattern and highest_pattern > 0:
		pattern = (pattern + 1) % (highest_pattern + 1)

	last_pattern = pattern

	return pattern


func _rain(amount: int, delay: float) -> void:
	for i in range(amount):
		var spawn_index := randi_range(0, active_spawn_count - 1)

		if randf() <= colored_bullet_chance:
			_spawn_colored(spawn_index)
		else:
			_spawn_neutral(spawn_index)

		await _wait(delay)


func _color_stream(amount: int, delay: float) -> void:
	var spawn_index := randi_range(0, active_spawn_count - 1)

	for i in range(amount):
		var color := randi_range(
			ColorHandler.Type.RED,
			ColorHandler.Type.BLUE
		)

		_spawn_colored(spawn_index, color)

		await _wait(delay)


func _wall_with_gap() -> void:
	var gap := randi_range(0, active_spawn_count - 1)

	for i in range(active_spawn_count):
		if i == gap:
			continue

		_spawn_neutral(i)

	await _wait(0.3)

	_spawn_colored(gap)


func _spawn_neutral(spawn_index: int) -> void:
	await _wait_for_boss()
	if not fight_active:
		return
	var projectile := _make_projectile(spawn_index)
	if projectile == null:
		return
	projectile.setup_neutral(boss)


func _spawn_colored(spawn_index: int, color := -1) -> void:
	await _wait_for_boss()
	if not fight_active:
		return
	var projectile := _make_projectile(spawn_index)
	if projectile == null:
		return
	if color == -1:
		color = randi_range(
			ColorHandler.Type.RED,
			ColorHandler.Type.BLUE
		)
	projectile.setup_colored(color, boss)


func _make_projectile(spawn_index: int) -> BossProjectile:
	if spawn_index < 0 or spawn_index >= spawn_points.size():
		return null
	var projectile := projectile_scene.instantiate() as BossProjectile
	if projectile == null:
		return null
	add_child(projectile)
	projectile.global_position = (
		spawn_points[spawn_index] as Node2D
	).global_position
	projectile.returned_to_boss.connect(
		_on_projectile_returned
	)
	projectile.hit_player.connect(
		_on_player_hit
	)
	return projectile


func _on_projectile_returned(_color: int) -> void:
	health -= 1
	boss_health_bar.value = health
	if health <= 0:
		_boss_died()
		return
	_update_phase()
	_hit_reaction()


func _on_player_hit() -> void:
	if player_dead or player_invulnerable:
		return
	player_health -= 1
	player_health_bar.value = player_health
	player_hit.emit()
	player.play_iframe_flash(player_invulnerability)
	if player_health <= 0:
		_player_died()
		return
	_player_invulnerability()

func _update_phase() -> void:
	var health_percent := float(health) / float(max_health)

	if health_percent > 0.66:
		active_spawn_count = mini(3, spawn_points.size())
	elif health_percent > 0.33:
		active_spawn_count = mini(5, spawn_points.size())
	else:
		active_spawn_count = spawn_points.size()


func _wait(seconds: float) -> void:
	var remaining := seconds
	while remaining > 0.0 and fight_active:
		await get_tree().process_frame
		if boss_stunned:
			continue
		remaining -= get_process_delta_time()


func _wait_for_hit_stun() -> void:
	while hit_stun_time > 0.0 and fight_active:
		await get_tree().process_frame

func _boss_died() -> void:
	fight_active = false
	boss_defeated.emit()
	_clear_projectiles()

func _player_died() -> void:
	player_dead = true
	fight_active = false
	player.die()
	_clear_projectiles()
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func _clear_projectiles() -> void:
	for projectile in get_tree().get_nodes_in_group("boss_projectile"):
		projectile.queue_free()
func _hit_reaction() -> void:
	if boss_stunned:
		return
	boss_stunned = true
	boss_hit.play()
	var original_position := boss.position
	var original_modulate := boss_sprite.modulate
	var elapsed := 0.0
	boss_sprite.modulate = Color(1.0, 0.35, 0.35)
	while elapsed < hit_stun_length:
		boss.position = original_position + Vector2(
			randf_range(-boss_shake_amount, boss_shake_amount),
			randf_range(-boss_shake_amount, boss_shake_amount)
		)
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	boss.position = original_position
	boss_sprite.modulate = original_modulate
	boss_stunned = false
func _wait_for_boss() -> void:
	while boss_stunned and fight_active:
		await get_tree().process_frame
func _player_invulnerability() -> void:
	player_invulnerable = true
	await get_tree().create_timer(player_invulnerability).timeout
	player_invulnerable = false
