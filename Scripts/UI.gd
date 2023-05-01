extends Node2D

var score: int = 0

var _paused: bool = false

func _ready() -> void:
	$BoatUI/BoatCount.text = str(score)

func _process(delta: float) -> void:
	var t = time_left()
	$TimeUI/TimeLeft.text = str(t / 60) + (":%02d" % (t % 60))

func time_left() -> int: # in seconds
	return int($TimeUI/Timer.time_left)

func increment_score():
	score += 1
	$BoatUI/BoatCount.text = str(score)

func game_over():
	get_tree().paused = true
	_paused = true
	$PauseUI.visible = true
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		game_over()
	elif event.is_action_pressed("Restart") and _paused:
		get_tree().reload_current_scene()
		get_tree().paused = false


func _on_Timer_timeout() -> void:
	game_over()


func _on_LandGrids_order_fulfilled(_dir) -> void:
	increment_score()
