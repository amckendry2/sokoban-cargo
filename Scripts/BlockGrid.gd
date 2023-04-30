class_name BlockGrid extends Node2D

signal push_ended

const animated_block_group_scene = preload("res://Scenes/AnimatedBlockGroup.tscn")
const BlockLogic = preload("res://Scripts/BlockLogic.gd")

var block_state: Dictionary = {}
var next_block_state: Dictionary = {}

func spawn_random_blocks(x_min: int, y_min: int, x_max: int, y_max: int, spawn_pct: float):
	for x in range(x_min, x_max):
		for y in range(y_min, y_max):
			var cell = Vector2(x, y)
			var emptyCell = not BlockLogic.findBlockAtPosition(cell, block_state)["foundBlock"]
			if emptyCell && rand_range(0, 1) < spawn_pct:
				var color = BlockLogic.getRandomColor()
				var new_block = BlockLogic.makeSingleCellBlock(cell, color)
				block_state[new_block] = null
	next_block_state = BlockLogic.fuseBlocks(block_state)
	update_state()
	
func delete_block(coord: Vector2):
	var block_to_delete = BlockLogic.findBlockAtPosition(coord, block_state)["foundBlock"]
	block_state.erase(block_to_delete)
	next_block_state = block_state
	update_state()

func move_blocks(moved_blocks: Dictionary, new_state: Dictionary, direction):
	var cleared_blocks_by_color = BlockLogic.partitionTilesByColor(moved_blocks)
	$BlueGrid.clear_blocks(cleared_blocks_by_color["blueBlocks"])
	$GreenGrid.clear_blocks(cleared_blocks_by_color["greenBlocks"])
	$OrangeGrid.clear_blocks(cleared_blocks_by_color["yellowBlocks"])

	# TODO(Julian): Some blocks become visually disconnected while being pushed.
	# Could be an issue in BlockLogic or with (Dynamic)TileMap
	for block in moved_blocks:
		var animated_block = animated_block_group_scene.instance()
		animated_block.init(direction, $BlockMoveTimer)
		animated_block.add_block(block)
		$AnimatedBlocks.add_child(animated_block)
	next_block_state = new_state
	$BlockMoveTimer.start()

func get_block_at_cursor(cursor_pos: Vector2) -> bool:
	return BlockLogic.findBlockAtPosition(cursor_pos, block_state)["foundBlock"]

func push_block(block_pos: Vector2, direction):
	var block_data = BlockLogic.findBlockAtPosition(block_pos, block_state)
	if block_data["foundBlock"] == null: return false
	
	var available_cells = $LandGrids.get_available_land_cells()
	var pushed_data = BlockLogic.pushBlock(direction, block_data["foundBlock"], block_data["otherBlocks"], available_cells)
	move_blocks(pushed_data["movedBlocks"], pushed_data["finalBlocks"], direction)
	return pushed_data["pushSuccessful"]

func update_state():
	$BlueGrid.clear()
	$GreenGrid.clear()
	$OrangeGrid.clear()
	block_state = next_block_state
	var color_separated_new_state = BlockLogic.partitionTilesByColor(block_state)
	$BlueGrid.add_blocks(color_separated_new_state["blueBlocks"])
	$GreenGrid.add_blocks(color_separated_new_state["greenBlocks"])
	$OrangeGrid.add_blocks(color_separated_new_state["yellowBlocks"])

func _on_BlockMoveTimer_timeout() -> void:
	update_state()
	emit_signal("push_ended")
