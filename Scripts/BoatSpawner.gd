extends Node2D

signal spawn_boat

export var no_boats_wait_time: float = 5
export var boats_docked_wait_time: float = 45

var _timer: float = 0
var _override_timer = false

func _process(delta: float) -> void:
	if not $"../BlockGrid/LandGrids".are_any_boats_docked() and not _override_timer:
		_override_timer = true
		_timer = 0

	if _override_timer:
		if _timer >= no_boats_wait_time:
			emit_signal("spawn_boat")
			_timer = 0
			_override_timer = false
	else:
		if _timer >= boats_docked_wait_time:
			emit_signal("spawn_boat")
			_timer = 0

	_timer += delta
	pass
