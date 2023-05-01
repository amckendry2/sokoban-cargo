class_name BlockGrid extends Node2D

signal push_ended

const animated_block_group_scene = preload("res://Scenes/AnimatedBlockGroup.tscn")
const BlockLogic = preload("res://Scripts/BlockLogic.gd")

var queued_blocks: Dictionary = {}

var shader_materials = {
	BlockLogic.BlockColor.GREEN: preload("res://Assets/Shaders/ChowderGreen.tres"),
	BlockLogic.BlockColor.ORANGE: preload("res://Assets/Shaders/ChowderOrange.tres"),
	BlockLogic.BlockColor.RED: preload("res://Assets/Shaders/ChowderRed.tres")
}

var tile_color_indexes = {
	BlockLogic.BlockColor.GREEN: 0,
	BlockLogic.BlockColor.ORANGE: 1,
	BlockLogic.BlockColor.RED: 2,
}

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
	
func queue_new_blocks(blocks: Dictionary):
	if $BlockMoveTimer.time_left > 0:
		for block in blocks:
			queued_blocks[block] = null
	else:
		add_new_blocks(blocks)
		
func add_new_blocks(blocks:Dictionary):
	for block in blocks:
		next_block_state[block] = null
	update_state()
		
	
func delete_block(coord: Vector2):
	var block_to_delete = BlockLogic.findBlockAtPosition(coord, block_state)["foundBlock"]
	block_state.erase(block_to_delete)
	next_block_state = block_state
	update_state()

func move_blocks(moved_blocks: Dictionary, new_state: Dictionary, direction):
	var cleared_blocks_by_color = BlockLogic.partitionTilesByColor(moved_blocks)
	$RedGrid.clear_blocks(cleared_blocks_by_color["redBlocks"])
	$GreenGrid.clear_blocks(cleared_blocks_by_color["greenBlocks"])
	$OrangeGrid.clear_blocks(cleared_blocks_by_color["orangeBlocks"])

	for block in moved_blocks:
		var animated_block = animated_block_group_scene.instance()
		var block_material = shader_materials[block.color]
		var tile_index = tile_color_indexes[block.color]
		animated_block.init(direction, $BlockMoveTimer, block_material, tile_index)
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
	$RedGrid.clear()
	$GreenGrid.clear()
	$OrangeGrid.clear()
	block_state = BlockLogic.fuseBlocks(next_block_state)
	var color_separated_new_state = BlockLogic.partitionTilesByColor(block_state)
	$RedGrid.add_blocks(color_separated_new_state["redBlocks"])
	$GreenGrid.add_blocks(color_separated_new_state["greenBlocks"])
	$OrangeGrid.add_blocks(color_separated_new_state["orangeBlocks"])

func _on_BlockMoveTimer_timeout() -> void:
	if len(queued_blocks.keys()) > 0:
		add_new_blocks(queued_blocks)
	queued_blocks = {}
	update_state()
	emit_signal("push_ended")
