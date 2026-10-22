extends Camera2D

@onready var target: CharacterBody2D = $".."

@export var follow_speed := 8.0
@export var jump_lift := -40.0   # how much the camera moves up during jump
@export var lift_speed := 6.0    # how fast the camera moves up/down

var vertical_offset := 0.0

func _ready():
	make_current()

func _process(delta):
	if not target:
		return

	# ⭐ Detect jump from player
	if target.is_jumping:
		# Move camera upward smoothly
		vertical_offset = lerp(vertical_offset, jump_lift, lift_speed * delta)
	else:
		# Return camera to normal smoothly
		vertical_offset = lerp(vertical_offset, 0.0, lift_speed * delta)

	# ⭐ Follow player with offset
	var desired_pos = target.global_position + Vector2(0, vertical_offset)
	global_position = global_position.lerp(desired_pos, follow_speed * delta)

	# ⭐ Clamp camera bounds
	global_position.x = clamp(global_position.x, 0, 8460)
	global_position.y = clamp(global_position.y, 0, 700)
