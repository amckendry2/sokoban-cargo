extends Node2D

const BlockLogic = preload("res://Scripts/BlockLogic.gd")

var selected: bool = false
var ignore_input: bool = false

var cursor_pos: Vector2

export var cursor_start_pos: Vector2 = Vector2(3, 3)
export var spawn_pct: float = 0.25
export var grid_x_min: int = 4
export var grid_x_max: int = 12
export var grid_y_min: int = 4
export var grid_y_max: int = 12
export var keep_blocks_selected: bool = true

func _ready():
	cursor_pos = cursor_start_pos
	$SelectionGrid.update_tile(cursor_pos)
#	$BlockGrid.initialize_state()

#	$BlockGrid.spawn_random_blocks(grid_x_min, grid_y_min, grid_x_max, grid_y_max, spawn_pct)

# move_dir: BlockLogic.MoveDirection
func move_cursor(move_dir):
	cursor_pos += BlockLogic.directionToVec((move_dir))

func _move(move_dir):
	if selected:
		ignore_input = true
		if $BlockGrid.push_block(cursor_pos, move_dir):
			move_cursor(move_dir)
	else:
		move_cursor(move_dir)
	$SelectionGrid.update_tile(cursor_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_just_pressed("test_queue")):
		var test_blocks = {}
		var test_cells_1 = {}
		test_cells_1[Vector2(5, 5)] = null
		test_cells_1[Vector2(5, 6)] = null
		var test_block_1 = {
			"cells": test_cells_1,
			"color": BlockLogic.BlockColor.GREEN
		}
		test_blocks[test_block_1] = null
		$BlockGrid.queue_new_blocks(test_blocks)
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
		elif(Input.is_action_just_pressed("delete_block")):
			if($BlockGrid.get_block_at_cursor(cursor_pos)):
				$BlockGrid.delete_block(cursor_pos)
func start_selection():
	selected = true
	$SelectionGrid.hide()

func end_selection():
	selected = false
	ignore_input = false
	$SelectionGrid.show()

func _on_BlockGrid_push_ended():
	ignore_input = false
	if not keep_blocks_selected: 
		end_selection()
