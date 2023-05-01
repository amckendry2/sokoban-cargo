class_name DockedBoatTileMap extends TileMap

var current_order: BoatOrder
export var top_left_cell_pos: Vector2
var _active: bool = false

func set_active(active):
	_active = active
	
func is_active():
	return _active

func is_order_fulfilled(grid: BlockGrid) -> bool:
	if not current_order: return false
	
	var cells = get_used_cells()
	for c in cells:
		var block = grid.get_block_at_cursor(c)
		if not block or block["color"] != current_order.get_color_at_cursor(c):
			return false
	return true
