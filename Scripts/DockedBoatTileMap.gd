extends TileMap

var _active: bool = true

func set_active(active):
	_active = active
	
func is_active():
	return _active

func is_order_fulfilled(grid: BlockGrid) -> bool:
	var cells = get_used_cells()
	for c in cells:
		var block = grid.get_block_at_cursor(c)
#		if not block or block["color"] != order.get_: # lookup Boat order to see if it matches
		if block:
			print(block) 
	
	return true
