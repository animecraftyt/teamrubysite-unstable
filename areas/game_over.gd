extends Node2D

@onready var audio_player: AudioStreamPlayer = $gameover

func _ready():
	audio_player.play()
	await audio_player.finished
	get_tree().change_scene_to_file("res://areas/title.tscn")
