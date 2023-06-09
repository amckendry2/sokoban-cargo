extends DynamicTileMap

const BlockLogic = preload("res://Scripts/BlockLogic.gd")
const tile_set_resource = preload("res://Assets/ArtTileSet.tres")

var _move_target: Vector2
var _timer: Timer = null
var _origin: Vector2

# direction: BlockLogic.MoveDirection
func init(direction, timer: Timer, block_material, _tile_index):
	_move_target = BlockLogic.directionToVec(direction) * 64
	_timer = timer
	_origin = position
	tile_index = _tile_index
	material = block_material

func _process(_delta: float) -> void:
	var t: float = 1 - (_timer.time_left / _timer.wait_time)
	position = _origin.linear_interpolate(_move_target, t)
	if _timer.time_left == 0:
		queue_free()
