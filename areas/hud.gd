extends CanvasLayer

@onready var time_label: Label = $Control/timelabel
@onready var score_label: Label = $Control/scorelabel
@onready var lives_label: Label = $Control/lifeslabel
@onready var rings_label: Label = $Control/rings

var time := 0.0
var score := 0
var lives := 3
var rings := 0

var flash_timer := 0.0
var flash_state := false

func _process(delta):

	# ⭐ STOP HUD TIMER WHEN GAME IS PAUSED
	if get_tree().paused:
		return

	# TIME
	time += delta
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)
	time_label.text = "TIME: %02d:%02d:%02d" % [minutes, seconds, milliseconds]

	# RING FLASHING WHEN ZERO
	if rings == 0:
		flash_timer += delta
		if flash_timer >= 0.25:
			flash_timer = 0.0
			flash_state = !flash_state

			if flash_state:
				rings_label.add_theme_color_override("font_color", Color.RED)
			else:
				rings_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		rings_label.add_theme_color_override("font_color", Color.WHITE)

func add_score(amount: int):
	score += amount
	score_label.text = "SCORE: %06d" % score

func set_lives(amount: int):
	lives = amount
	lives_label.text = str(lives)

func set_rings(amount: int):
	rings = amount
	rings_label.text = "RINGS: " + str(rings)

func reset_time():
	time = 0.0
