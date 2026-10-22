extends Node2D

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var start: AudioStreamPlayer = $Select
func _ready():
	audio_player.stream.loop = true
	audio_player.play()

func _process(_delta):
	if Input.is_action_just_pressed("start"):
		start.play()
		await start.finished
		get_tree().change_scene_to_file("res://areas/char_select.tscn")

	
