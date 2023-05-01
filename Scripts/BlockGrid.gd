class_name BlockGrid extends Node2D

signal push_ended

const animated_block_group_scene = preload("res://Scenes/AnimatedBlockGroup.tscn")

var shader_materials = {
	BlockLogicAuto.BlockColor.GREEN: preload("res://Assets/Shaders/ChowderGreen.tres"),
	BlockLogicAuto.BlockColor.ORANGE: preload("res://Assets/Shaders/ChowderOrange.tres"),
	BlockLogicAuto.BlockColor.RED: preload("res://Assets/Shaders/ChowderRed.tres")
}

var tile_color_indexes = {
	BlockLogicAuto.BlockColor.GREEN: 0,
	BlockLogicAuto.BlockColor.ORANGE: 1,
	BlockLogicAuto.BlockColor.RED: 2,
}

var block_state: Dictionary = {}
var next_block_state: Dictionary = {}

func spawn_random_blocks(x_min: int, y_min: int, x_max: int, y_max: int, spawn_pct: float):
	for x in range(x_min, x_max):
		for y in range(y_min, y_max):
			var cell = Vector2(x, y)
			var emptyCell = not BlockLogicAuto.findBlockAtPosition(cell, block_state)["foundBlock"]
			if emptyCell && rand_range(0, 1) < spawn_pct:
				var color = BlockLogicAuto.getRandomColor()
				var new_block = BlockLogicAuto.makeSingleCellBlock(cell, color)
				block_state[new_block] = null
	next_block_state = BlockLogicAuto.fuseBlocks(block_state)
	update_state()

func queue_new_blocks(blocks: Dictionary):
	if $BlockMoveTimer.time_left > 0:
		for block in blocks:
			next_block_state[block] = null
	else:
		add_new_blocks(blocks)

func add_new_blocks(blocks:Dictionary):
	for block in blocks:
		next_block_state[block] = null
	update_state()

func delete_cells_from_blocks(cells: Dictionary):
	var acc = {}
	for block in next_block_state:
		var new_block = block.duplicate()
		new_block.cells = BlockLogic.diffDicts(block.cells, cells)
		if new_block.cells.size() > 0:
			acc[new_block] = null
#		next_block_state.erase(block)
#		next_block_state[new_block] = null
	next_block_state = acc
	update_state()
	
#func delete_block(coord: Vector2):
#	var block_to_delete = BlockLogicAuto.findBlockAtPosition(coord, block_state)["foundBlock"]
#	block_state.erase(block_to_delete)
#	next_block_state = block_state
#	update_state()

func move_blocks(moved_blocks: Dictionary, new_state: Dictionary, direction):
	var cleared_blocks_by_color = BlockLogicAuto.partitionTilesByColor(moved_blocks)
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

func get_block_at_cursor(cursor_pos: Vector2) -> Dictionary:
	return BlockLogic.findBlockAtPosition(cursor_pos, block_state)["foundBlock"]

func push_block(block_pos: Vector2, direction):
	var block_data = BlockLogicAuto.findBlockAtPosition(block_pos, block_state)
	if block_data["foundBlock"] == null: return false

	var available_cells = $LandGrids.get_available_land_cells()
	var pushed_data = BlockLogicAuto.pushBlock(direction, block_data["foundBlock"], block_data["otherBlocks"], available_cells)
	move_blocks(pushed_data["movedBlocks"], pushed_data["finalBlocks"], direction)
	return pushed_data["pushSuccessful"]

func update_state():
	$RedGrid.clear()
	$GreenGrid.clear()
	$OrangeGrid.clear()
	block_state = next_block_state
	var color_separated_new_state = BlockLogicAuto.partitionTilesByColor(block_state)
	$RedGrid.add_blocks(color_separated_new_state["redBlocks"])
	$GreenGrid.add_blocks(color_separated_new_state["greenBlocks"])
	$OrangeGrid.add_blocks(color_separated_new_state["orangeBlocks"])

func _on_BlockMoveTimer_timeout() -> void:
	update_state()
	emit_signal("push_ended")
