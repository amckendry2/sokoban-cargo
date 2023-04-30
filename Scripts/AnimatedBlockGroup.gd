extends DynamicTileMap

const animated_block_scene = preload("res://Scenes/AnimatedBlock.tscn")
const block_textures = [
	preload("res://Assets/Textures/icon.png")
]

var _move_target: Vector2
var _timer: Timer = null

func _ready() -> void:
	global_position = Vector2(0,0)

func add_cell(grid_coord: Vector2, _texture_idx: int):
#	var block = animated_block_scene.instance()
#	block.initialize(block_textures[texture_idx], grid_coord)
#	$Blocks.add_child(block)
	set_cellv(grid_coord, 1)
	update_bitmask_area(grid_coord)
	pass

# direction: BlockLogic.MoveDirection
func init(direction, timer: Timer):
	_move_target = BlockLogic.directionToVec(direction) * 64
	_timer = timer

func _process(_delta: float) -> void:
	var t: float = 1 - (_timer.time_left / _timer.wait_time)

	global_position = global_position.linear_interpolate(_move_target, t)
	if _timer.time_left == 0:
		queue_free()
