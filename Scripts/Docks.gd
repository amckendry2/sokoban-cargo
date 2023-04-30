extends Node2D

const animated_block_scene = preload("res://Scenes/AnimatedBlock.tscn")
const BlockLogic = preload("res://Scripts/BlockLogic.gd")

var selected: bool = false
var ignore_input: bool = false

var cursor_pos: Vector2 = Vector2(3, 3)

func _ready():
	$SelectionGrid.update_tile(cursor_pos)
	$BlockGrid.initialize_state()

# move_dir: BlockLogic.MoveDirection
func _move(move_dir):
	if selected:
		$BlockGrid.push_block(cursor_pos, move_dir)
		ignore_input = true
	cursor_pos += BlockLogic.directionToVec(move_dir)
	$SelectionGrid.update_tile(cursor_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not ignore_input:
		if(Input.is_action_just_pressed("move_up")):
			_move(BlockLogic.MoveDirection.NORTH)
		elif(Input.is_action_just_pressed("move_down")):
			_move(BlockLogic.MoveDirection.SOUTH)
		elif(Input.is_action_just_pressed("move_left")):
			_move(BlockLogic.MoveDirection.WEST)
		elif(Input.is_action_just_pressed("move_right")):
			_move(BlockLogic.MoveDirection.EAST)
		elif(Input.is_action_just_pressed("select_block")):
			if selected:
				end_selection()
			else:
				if ($BlockGrid.get_block_at_cursor(cursor_pos)):
					start_selection()

func start_selection():
	selected = true
	$SelectionGrid.hide()

func end_selection():
	selected = false
	$SelectionGrid.show()

func _on_BlockGrid_push_ended():
	ignore_input = false
	end_selection()
