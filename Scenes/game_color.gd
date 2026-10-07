class_name GameColor
extends RefCounted

signal color_changed

enum Type {
	RED,
	YELLOW,
	BLUE
}

func emit_color_change():
	color_changed.emit()

static func visual_color(value: int) -> Color:
	match value:
		Type.RED:
			return Color(1.0, 0.15, 0.2)

		Type.YELLOW:
			return Color(1.0, 0.85, 0.1)

		Type.BLUE:
			return Color(0.2, 0.45, 1.0)

	return Color.WHITE
