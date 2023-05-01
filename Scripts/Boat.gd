extends Node2D

class_name Boat

export var direction: String

var _top_left_cell: Vector2
var _top_left_pos: Vector2
var _incoming_blocks: Dictionary
var _outgoing_blocks: Dictionary

signal docking_finished

var docked: bool = false
var exiting: bool = false

var tile_color_indexes = {
	BlockLogicAuto.BlockColor.GREEN: 0,
	BlockLogicAuto.BlockColor.ORANGE: 1,
	BlockLogicAuto.BlockColor.RED: 2,
}
	
func initialize(incoming_boat_order: BoatOrder, outgoing_boat_order: BoatOrder, top_left_cell: Vector2):
	_top_left_cell = top_left_cell
	_top_left_pos = top_left_cell * 64 + Vector2(64, 64)
	_incoming_blocks = incoming_boat_order._blocks
	_outgoing_blocks = outgoing_boat_order._blocks
	hide_hint()
	for block in incoming_boat_order._blocks:
		var tilemap = [$Visual/EelGreenTileMap, $Visual/EelOrangeTileMap, $Visual/EelRedTileMap][block.color]
		add_block_to_tilemap(block, tilemap)
	for block in outgoing_boat_order._blocks:	
		var hint_tilemap = [$Visual/HintGreenTileMap, $Visual/HintOrangeTileMap, $Visual/HintRedTileMap][block.color]
		add_block_to_tilemap(block, hint_tilemap)

func add_block_to_tilemap(block: Dictionary, tilemap: TileMap):
	var global_block = block.duplicate()
	var local_cells = {}
	for cell in global_block.cells:
		local_cells[cell - _top_left_cell] = null
	var local_block = {"cells": local_cells, "color": block.color}	
	tilemap.add_block(local_block)
	
func hide_hint():
	$Visual/MessageBubble.hide()
	$Visual/HintRedTileMap.hide()
	$Visual/HintOrangeTileMap.hide()
	$Visual/HintGreenTileMap.hide()
	
func show_hint():
	$Visual/MessageBubble.show()
	$Visual/HintRedTileMap.show()
	$Visual/HintOrangeTileMap.show()
	$Visual/HintGreenTileMap.show()
		
func _process(delta):
	if not docked:
		var path = $EnterPath2D/PathFollow2D
		move_on_path(path, delta)
		if path.get_unit_offset() == 1:
			delete_blocks()
			emit_signal("docking_finished", {"direction": direction, "blocks": _incoming_blocks})
			docked = true
			show_hint()
	if exiting:
		hide_hint()
		var path = $ExitPath2D/PathFollow2D
		move_on_path(path, delta)
		if path.get_unit_offset() == 1:
			queue_free()

func start_exit():
	exiting = true
	for block in _outgoing_blocks:
		var tilemap = [$Visual/EelGreenTileMap, $Visual/EelOrangeTileMap, $Visual/EelRedTileMap][block.color]
		add_block_to_tilemap(block, tilemap)
	

func move_on_path(path, delta):
	path.set_offset(path.get_offset() + delta * 150)
	position = path.position + _top_left_pos
	rotation = path.rotation + PI / 2


func delete_blocks():
	$Visual/EelGreenTileMap.clear()
	$Visual/EelOrangeTileMap.clear()
	$Visual/EelRedTileMap.clear()
					
