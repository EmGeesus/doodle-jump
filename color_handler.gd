extends Node


signal color_changed(new_color: int)
enum Type {
	RED,
	YELLOW,
	BLUE
}

var color = Color.WHITE

func get_current_color() -> Color:
	return color

func emit_color_change():
	color_changed.emit()

func set_color(value: int):
	var color_changed = false
	if not color == translate(value):
		color_changed = true
	match value:
		Type.RED:
			color = Color(1.0, 0.15, 0.2)
		
		Type.YELLOW:
			color = Color(1.0, 0.85, 0.1)
		
		Type.BLUE:
			color =Color(0.2, 0.45, 1.0)
		
		_:
			color = Color.WHITE
	if color_changed:
		emit_color_change()

static func get_random_color(level: int = 7):
	if level <= 1:
		return int(Type.RED)
	if level <= 5:
		return randi_range(
					Type.RED,
					Type.YELLOW
				)
	return randi_range(
			Type.RED,
			Type.BLUE
		)


##Input a Type.COLOR and get the actual color out
static func translate(value: int) -> Color:
	match value:
		Type.RED:
			return Color(1.0, 0.15, 0.2)

		Type.YELLOW:
			return Color(1.0, 0.85, 0.1)

		Type.BLUE:
			return Color(0.2, 0.45, 1.0)

	return Color.WHITE
