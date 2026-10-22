extends Node2D

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	audio_player.stream.loop = true
	audio_player.play()

func _process(_delta):
	if Input.is_action_just_pressed("start"):
		get_tree().change_scene_to_file("res://areas/level.tscn")
