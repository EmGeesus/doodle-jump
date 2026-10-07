extends Node2D

@export var collision_shape_2d: CollisionShape2D


func _ready():
	ColorHandler.color_changed.connect(_on_color_changed)








func _on_color_changed():
	collision_shape_2d.disabled = not collision_shape_2d.disabled
