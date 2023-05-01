class_name BoatOrder extends Resource

var _blocks: Dictionary = {} # BlockLogic.Block

# probability to fill cell for this block
# if a cell is already occupied or the probability fails, skip

static func generate(dock, top_left: Vector2) -> Dictionary:
	# Generate a blocks dict in a 2x4 grid
	var x_len = 2 if (dock == BlockLogicAuto.MoveDirection.EAST or dock == BlockLogicAuto.MoveDirection.WEST) else 4
	var y_len = 4 if (dock == BlockLogicAuto.MoveDirection.EAST or dock == BlockLogicAuto.MoveDirection.WEST) else 2

	var total_cells = 2 * 4

	# Randomize colors
	var random_gen: RandomNumberGenerator = RandomNumberGenerator.new()
	random_gen.randomize()

	var color_list = [BlockLogicAuto.BlockColor.GREEN, BlockLogicAuto.BlockColor.RED, BlockLogicAuto.BlockColor.ORANGE]
	color_list.shuffle()
	var color_cumulative_probabilities = [0.33, 0.66, 1.0]
	var color_counts = {}
	for _unused in range(total_cells):
		var rand = random_gen.randf()
		for i in range(len(color_list)):
			if rand <= color_cumulative_probabilities[i]:
				var color = color_list[i]
				if color_counts.has(color):
					color_counts[color] += 1
				else:
					color_counts[color] = 1
				break

	var color_path = []
	for color in color_counts:
		var count = color_counts[color]
		for _unused in range(count):
			color_path.push_back(color)

	var color_idx = 0
	var singleton_blocks = {}
	for y in range(top_left.y, top_left.y + y_len):
		var go_right = y % 2 == 0
		var x_start = top_left.x if go_right else top_left.x + x_len - 1
		var x_end = top_left.x + x_len if go_right else top_left.x - 1
		var increment = 1 if go_right else -1

		for x in range(x_start, x_end, increment):
			var color = color_path[color_idx]
			var new_singleton_block = BlockLogicAuto.makeBlock({ Vector2(x, y): null }, color)
			singleton_blocks[new_singleton_block] = null
			color_idx += 1

	return BlockLogicAuto.fuseBlocks(singleton_blocks)

func _init(dock, top_left: Vector2):
	_blocks = generate(dock, top_left)

func get_color_at_cursor(cursor: Vector2):
	var block = BlockLogicAuto.findBlockAtPosition(cursor, _blocks)
	if not block["found_block"]: return null
	return block["found_block"]["color"]
