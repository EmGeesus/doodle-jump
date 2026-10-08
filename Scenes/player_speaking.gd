extends AnimationPlayer


@onready var label = $Label
@onready var text_animate = $"text animate"

func play_animation_with_text(dialouge: Array):
	play("start_speak")
	await animation_finished
	play("speak")
	for speak in dialouge:
		label.text = speak
		text_animate.play("speak")
		await text_animate.animation_finished
	play_backwards("start_speak")
