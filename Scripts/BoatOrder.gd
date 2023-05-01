class_name BoatOrder extends Resource

var _blocks: Dictionary = {} # BlockLogic.Block

# probability to fill cell for this block
# if a cell is already occupied or the probability fails, skip

static func generate(dock, top_left: Vector2) -> BoatOrder:
	# Generate a blocks dict in a 3x4 grid
	var x_len = 3 if (dock is BlockLogicAuto.MoveDirection.EAST or dock is BlockLogicAuto.MoveDirection.WEST) else 4
	var y_len = 4 if (dock is BlockLogicAuto.MoveDirection.EAST or dock is BlockLogicAuto.MoveDirection.WEST) else 3
	
	# how many colors in this order
	# how many cells for this color
	# order of colors in sweep
	
	var color_list = [BlockLogicAuto.BlockColor.GREEN, BlockLogicAuto.BlockColor.RED, BlockLogicAuto.BlockColor.ORANGE].shuffle()
	var color_idx = 0
	
	var cells_per_block = 3 * 4 / 3
	var filled_cells_count = 0
	
	for y in range(top_left.y, top_left.y + y_len):
		var go_right = y % 2 == 0 
		var x_start = top_left.x if go_right else top_left.x + x_len - 1
		var x_end =  top_left.x + x_len if go_right else top_left.x
		var increment = 1 if go_right else -1
		
		for x in range(x_start, x_end, increment):
			if filled_cells_count >= cells_per_block:
				filled_cells_count = 0
				color_idx += 1
				
			
			pass
	
#	for x in range(top_left.x, top_left.x + x_len):
#		for y in range(top_left.y, top_left.y + y_len):
#			# fill _blocks with cells
#			pass
			
	return null	

func get_color_at_cursor(cursor: Vector2):
	var block = BlockLogic.findBlockAtPosition(cursor, _blocks)
	if not block["found_block"]: return null
	return block["found_block"]["color"]
