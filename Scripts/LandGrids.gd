extends Node2D

signal order_fulfilled

onready var boat_grids = {
	BlockLogicAuto.MoveDirection.NORTH: $BoatNorthGrid,
	BlockLogicAuto.MoveDirection.SOUTH: $BoatSouthGrid,
	BlockLogicAuto.MoveDirection.EAST: $BoatEastGrid,
	BlockLogicAuto.MoveDirection.WEST: $BoatWestGrid,
}

func array_to_set(arr: Array):
	var acc = {}
	for value in arr:
		acc[value] = null
	return acc

func get_available_land_cells():
	var all_cells = $LandGrid.get_used_cells()
	for dir in boat_grids:
		if boat_grids[dir].is_active():
			all_cells += boat_grids[dir].get_used_cells()
			
	var set = array_to_set(all_cells)
	return set

func _on_BlockGrid_push_ended():
	var block_grid = $"../../BlockGrid"
	for dir in boat_grids:
		if boat_grids[dir].is_active():
			if boat_grids[dir].is_order_fulfilled(block_grid):
				block_grid.delete_cells_from_blocks(array_to_set(boat_grids[dir].get_used_cells()))
				boat_grids[dir].launch_boat()
				emit_signal("order_fulfilled", dir)
