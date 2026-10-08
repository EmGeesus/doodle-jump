extends CanvasLayer
@onready var color_rect: ColorRect = $ColorRect

var player: CharacterBody2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	ColorHandler.color_changed.connect(_on_color_changed)

func _on_color_changed():
	var temp_color = ColorHandler.get_current_color()
	temp_color.a = .2
	trigger_colored_ripple(player.get_global_transform_with_canvas().get_origin(),temp_color)

func trigger_colored_ripple(screen_position: Vector2, ripple_color: Color) -> void:
	var view_size = get_viewport().get_visible_rect().size
	var uv_pos = screen_position / view_size

	var material = color_rect.material as ShaderMaterial
	material.set_shader_parameter("center", uv_pos)

	material.set_shader_parameter("tint_color", ripple_color)

	material.set_shader_parameter("size", 0.1)
	material.set_shader_parameter("force", 0.05)

	var tween = create_tween()

	tween.tween_method(
		func(val): material.set_shader_parameter("size", val),
		0.0, 1.8, 0.8
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	tween.parallel().tween_method(
		func(val): material.set_shader_parameter("force", val),
		0.05, 0.0, 0.8
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
