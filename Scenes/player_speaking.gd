extends AnimationPlayer


@onready var label = $Label
@onready var text_animate = $"text animate"
signal full_speak_done
var full_playing = false

func play_animation_with_text(dialouge: Array):
	full_playing = true
	play("start_speak")
	await animation_finished
	play("speak")
	for speak in dialouge:
		label.text = speak
		text_animate.play("speak")
		await text_animate.animation_finished
	play_backwards("start_speak")
	await animation_finished
	full_speak_done.emit()
	full_playing = false

func play_animation_boss_with_text(dialouge: Array):
	full_playing = true
	play("start_boss_speak")
	await animation_finished
	play("boss_speak")
	for speak in dialouge:
		label.text = speak
		text_animate.play("speak")
		await text_animate.animation_finished
	play_backwards("start_boss_speak")
	await animation_finished
	full_speak_done.emit()
	full_playing = false
