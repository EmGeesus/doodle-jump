extends Node2D
@onready var player_speaking = $Player_Speaking

func play_animation_with_text(input: Array):
	player_speaking.play_animation_with_text(input)
