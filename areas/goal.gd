extends Area2D


@onready var anim: AnimatedSprite2D = $anim
@onready var goalspin: AudioStreamPlayer = $Signspin

var activated := false

func _ready():
	anim.play("normal")

func _on_body_entered(body):
	if activated:
		return

	if body.name == "player":
		activated = true

		# Spin animation + sound
		anim.play("spin")
		goalspin.play()

		# Tell player the goal was reached (player freezes)
		body.reach_goal()

		# Wait for spin animation to finish
		await anim.animation_finished

		# Wait for sound to finish
		await goalspin.finished

		# Now play the sign's win animation
		anim.play("win")

		# Wait for win animation to finish
		await anim.animation_finished
