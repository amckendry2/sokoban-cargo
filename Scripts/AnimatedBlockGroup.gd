extends DynamicTileMap

var _move_target: Vector2
var _timer: Timer = null

func _ready() -> void:
	global_position = Vector2(0,0)

# direction: BlockLogic.MoveDirection
func init(direction, timer: Timer):
	_move_target = BlockLogic.directionToVec(direction) * 64
	_timer = timer

func _process(_delta: float) -> void:
	var t: float = 1 - (_timer.time_left / _timer.wait_time)
	global_position = global_position.linear_interpolate(_move_target, t)
	if _timer.time_left == 0:
		queue_free()
