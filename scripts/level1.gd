extends Node2D

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var pause_audio: AudioStreamPlayer = $Pause
@onready var paused_sprite: Sprite2D = $CanvasLayer/Paused

var is_paused := false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS   # keep processing even when paused

	audio_player.stream.loop = true
	audio_player.play()
	paused_sprite.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("start"):
		pause_audio.play()
		is_paused = !is_paused

		if is_paused:
			get_tree().paused = true
			paused_sprite.visible = true
			audio_player.stream_paused = true   # pause the BGM
		else:
			get_tree().paused = false
			paused_sprite.visible = false
			audio_player.stream_paused = false  # resume the BGM
