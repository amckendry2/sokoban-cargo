extends Node2D

export var direction: String

var _top_left_pos: Vector2
var _blocks: Dictionary

signal docking_finished

var docked: bool = false

var tile_color_indexes = {
	BlockLogicAuto.BlockColor.GREEN: 0,
	BlockLogicAuto.BlockColor.ORANGE: 1,
	BlockLogicAuto.BlockColor.RED: 2,
}
	
func initialize(boat_order: BoatOrder, top_left_cell: Vector2):
	_top_left_pos = top_left_cell * 64 + Vector2(64, 64)
	_blocks = boat_order._blocks
	for block in boat_order._blocks:
		var tilemap = [$Visual/EelGreenTileMap, $Visual/EelOrangeTileMap, $Visual/EelRedTileMap][block.color]
		var global_block = block.duplicate()
		var local_cells = {}
		for cell in global_block.cells:
			local_cells[cell - top_left_cell] = null
		tilemap.add_block({"cells": local_cells, "color": block.color})

func _process(delta):
	var path = $Path2D/PathFollow2D
	path.set_offset(path.get_offset() + delta * 100)
	position = path.position + _top_left_pos
	rotation = path.rotation + PI / 2
	if not docked and path.get_unit_offset() == 1:
		hide_blocks()
		emit_signal("docking_finished", {"direction": direction, "blocks": _blocks})
		docked = true

func hide_blocks():
	$Visual/EelGreenTileMap.hide()
	$Visual/EelOrangeTileMap.hide()
	$Visual/EelRedTileMap.hide()
				
			
