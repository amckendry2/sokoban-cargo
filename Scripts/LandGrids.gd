extends Node2D

onready var boat_grids = {
	"north": $BoatNorthGrid,
	"south": $BoatSouthGrid,
	"east": $BoatEastGrid,
	"west": $BoatWestGrid,
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
	for dir in boat_grids:
		if boat_grids[dir].is_active():
			boat_grids[dir].is_order_fulfilled($"../../BlockGrid")
	pass
