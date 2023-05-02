class_name BoatOrder extends Resource

var _blocks: Dictionary = {} # BlockLogic.Block

func _init(dock, top_left: Vector2, color_counts = null):
	_blocks = generate(dock, top_left, color_counts)

static func generate(dock, top_left: Vector2, color_counts = null) -> Dictionary:
	# Generate a blocks dict in a 2x4 grid
	var x_len = 2 if (dock == BlockLogicAuto.MoveDirection.EAST or dock == BlockLogicAuto.MoveDirection.WEST) else 4
	var y_len = 4 if (dock == BlockLogicAuto.MoveDirection.EAST or dock == BlockLogicAuto.MoveDirection.WEST) else 2

	var total_cells = (2 * 4) - 2 # change this to affect how many cells are spawned

	# Randomize colors
	var random_gen: RandomNumberGenerator = RandomNumberGenerator.new()
	random_gen.randomize()

	var color_path: Array
	if color_counts:
		color_path = _generate_from_grid(random_gen, total_cells, color_counts)
	else:
		color_path = _generate_random_distribution(random_gen, total_cells)

	var color_idx = 0
	var singleton_blocks = {}
	for y in range(top_left.y, top_left.y + y_len):
		var go_right = y % 2 == 0
		var x_start = top_left.x if go_right else top_left.x + x_len - 1
		var x_end = top_left.x + x_len if go_right else top_left.x - 1
		var increment = 1 if go_right else -1

		for x in range(x_start, x_end, increment):
			if color_idx >= len(color_path): break
			var color = color_path[color_idx]
			var new_singleton_block = BlockLogicAuto.makeBlock({ Vector2(x, y): null }, color)
			singleton_blocks[new_singleton_block] = null
			color_idx += 1

	return BlockLogicAuto.fuseBlocks(singleton_blocks)

static func _generate_from_grid(random_gen: RandomNumberGenerator, total_cells: int, color_counts: Dictionary) -> Array:
	var color_list = [
				BlockLogicAuto.BlockColor.GREEN,
				BlockLogicAuto.BlockColor.ORANGE,
				BlockLogicAuto.BlockColor.RED
			]
	var outgoing_color_counts = {}

	var local_color_counts = color_counts.duplicate(true)
	for n in range(total_cells):
		# count cells, make probabilities
		var num_green_cumulative = local_color_counts[BlockLogicAuto.BlockColor.GREEN]
		var num_orange_cumulative = num_green_cumulative +local_color_counts[BlockLogicAuto.BlockColor.ORANGE]
		var num_red_cumulative = num_orange_cumulative +local_color_counts[BlockLogicAuto.BlockColor.RED]
		if num_red_cumulative <= 0: break # sometimes this is zero for some reason
		var color_cumulative_probabilities = \
					[ num_green_cumulative / num_red_cumulative,
						num_orange_cumulative / num_red_cumulative,
						num_red_cumulative / num_red_cumulative
					]
		# sample color from probabilities, update counts to avoid replacement
		var rand = random_gen.randf()
		for i in range(len(color_list)):
			if rand <= color_cumulative_probabilities[i]:
				var color = color_list[i]
				if outgoing_color_counts.has(color):
					outgoing_color_counts[color] += 1
				else:
					outgoing_color_counts[color] = 1
				local_color_counts[color] -= 1
				break

	var outgoing_color_counts_pairs = []
	for color in outgoing_color_counts:
		outgoing_color_counts_pairs.push_back({"color": color, "count": outgoing_color_counts[color]})
	outgoing_color_counts_pairs.shuffle()

	var color_path = []
	for pair in outgoing_color_counts_pairs:
		for _unused in range(pair.count):
			color_path.push_back(pair.color)

	return color_path

static func _floori(f: float) -> int :
	return int(floor(f))

static func _generate_random_distribution(random_gen: RandomNumberGenerator, total_cells: int) -> Array:
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

	return color_path

func get_color_at_cursor(cursor: Vector2):
	var block = BlockLogicAuto.findBlockAtPosition(cursor, _blocks)
	if not block["foundBlock"]: return null
	return block["foundBlock"]["color"]
