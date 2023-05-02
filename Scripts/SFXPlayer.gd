extends Node2D

var boat_move = preload("res://Assets/Music/sokoban-cargo-boat-movement-sound.wav")
var eel_move = preload("res://Assets/Music/sokoban-cargo-eel-movement-sound.wav")

enum FX {boat, eelmove}

#func play_sound(fx, parent: Node2D):
#	var player = AudioStreamPlayer.new()
#	match fx:
#		FX.boat:
#			player.stream = boat_move
#			parent.add_child(player)
#		FX.eelmove:
#			player.stream = boat_move
#			parent.add_child(this)
#	pass
