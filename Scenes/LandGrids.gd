extends Node2D

func get_available_land_cells():
	var north_cells = $BoatNorthGrid.get_used_cells() if $BoatNorthGrid.is_active() else []
	var east_cells = $BoatEastGrid.get_used_cells() if $BoatEastGrid.is_active() else []
	var south_cells = $BoatSouthGrid.get_used_cells() if $BoatSouthGrid.is_active() else []
	var west_cells = $BoatWestGrid.get_used_cells() if $BoatWestGrid.is_active() else []
	return $LandGrid.get_used_cells() + north_cells + east_cells + south_cells + west_cells
