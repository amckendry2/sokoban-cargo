extends Node2D

signal push_ended

const animated_block_group_scene = preload("res://Scenes/AnimatedBlockGroup.tscn")
const BlockLogic = preload("res://Scripts/BlockLogic.gd")

var block_state: Dictionary = {}
var next_block_state: Dictionary = {}

func initialize_state():
	var new_state = {}
	var red_block_cells = {}
	red_block_cells[Vector2(2, 3)] = null
	red_block_cells[Vector2(3, 3)] = null
	red_block_cells[Vector2(3, 4)] = null
	var red_block = {
		"cells": red_block_cells,
		"color": BlockLogic.BlockColor.RED
	}
	var green_block_cells = {}
	green_block_cells[Vector2(1, 2)] = null
	green_block_cells[Vector2(2, 2)] = null
	green_block_cells[Vector2(3, 2)] = null
	var green_block = {
		"cells": green_block_cells,
		"color": BlockLogic.BlockColor.GREEN
	}
	var yellow_block_cells = {}
	yellow_block_cells[Vector2(2, 4)] = null
	var yellow_block = {
		"cells": yellow_block_cells,
		"color": BlockLogic.BlockColor.YELLOW
	}
	var blue_block_cells = {}
	blue_block_cells[Vector2(3, 5)] = null
	var blue_block = {
		"cells": blue_block_cells,
		"color": BlockLogic.BlockColor.BLUE
	}
	new_state[red_block] = null
	new_state[green_block] = null
	new_state[yellow_block] = null
	new_state[blue_block] = null
	next_block_state = new_state
	update_state()

func move_blocks(moved_blocks: Dictionary, new_state: Dictionary, direction):
	var cleared_blocks_by_color = BlockLogic.partitionTilesByColor(moved_blocks)
	$RedGrid.clear_blocks(cleared_blocks_by_color["redBlocks"])
	$BlueGrid.clear_blocks(cleared_blocks_by_color["blueBlocks"])
	$GreenGrid.clear_blocks(cleared_blocks_by_color["greenBlocks"])
	$OrangeGrid.clear_blocks(cleared_blocks_by_color["yellowBlocks"])

	for block in moved_blocks:
		var animated_block = animated_block_group_scene.instance()
		animated_block.init(direction, $BlockMoveTimer)
		animated_block.add_block(block)
		$AnimatedBlocks.add_child(animated_block)
	next_block_state = new_state
	$BlockMoveTimer.start()

func get_block_at_cursor(cursor_pos: Vector2):
	return BlockLogic.findBlockAtPosition(cursor_pos, block_state)["foundBlock"]

func push_block(block_pos: Vector2, direction):
	var block_data = BlockLogic.findBlockAtPosition(block_pos, block_state)
	if block_data["foundBlock"] == null: return

	var pushed_data = BlockLogic.pushBlock(direction, block_data["foundBlock"], block_data["otherBlocks"])
	move_blocks(pushed_data["movedBlocks"], pushed_data["finalBlocks"], direction)

func update_state():
	$RedGrid.clear()
	$BlueGrid.clear()
	$GreenGrid.clear()
	$OrangeGrid.clear()
	block_state = next_block_state
	var color_separated_new_state = BlockLogic.partitionTilesByColor(block_state)
	$RedGrid.add_blocks(color_separated_new_state["redBlocks"])
	$BlueGrid.add_blocks(color_separated_new_state["blueBlocks"])
	$GreenGrid.add_blocks(color_separated_new_state["greenBlocks"])
	$OrangeGrid.add_blocks(color_separated_new_state["yellowBlocks"])

func _on_BlockMoveTimer_timeout() -> void:
	update_state()
	emit_signal("push_ended")
