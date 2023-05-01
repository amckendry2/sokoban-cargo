extends Node2D

const boat_scenes = {
	BlockLogicAuto.MoveDirection.WEST: preload("res://Nodes/BoatWest.tscn"),
	BlockLogicAuto.MoveDirection.EAST: preload("res://Nodes/BoatEast.tscn"),
	BlockLogicAuto.MoveDirection.SOUTH: preload("res://Nodes/BoatSouth.tscn"),
	BlockLogicAuto.MoveDirection.NORTH: preload("res://Nodes/BoatNorth.tscn")
}

var selected: bool = false
var ignore_input: bool = false

var cursor_pos: Vector2

export var cursor_start_pos: Vector2 = Vector2(7, 7)
export var spawn_pct: float = 0.25
export var grid_x_min: int = 4
export var grid_x_max: int = 12
export var grid_y_min: int = 4
export var grid_y_max: int = 12
export var keep_blocks_selected: bool = true

var min_cursor_coordinate: int = 2
var max_cursor_coordinate: int = 11

func _ready():
	randomize()
	cursor_pos = cursor_start_pos
	$SelectionGrid.update_tile(cursor_pos)
	$BlockGrid.spawn_random_blocks(grid_x_min, grid_y_min, grid_x_max, grid_y_max, spawn_pct)
	spawn_boat()

# move_dir: BlockLogicAuto.MoveDirection
func move_cursor(move_dir):
	cursor_pos += BlockLogicAuto.directionToVec((move_dir))
	bound_cursor_pos()

func bound_cursor_pos():
	if cursor_pos[0] < min_cursor_coordinate:
		cursor_pos[0] = min_cursor_coordinate
	if cursor_pos[1] < min_cursor_coordinate:
		cursor_pos[1] = min_cursor_coordinate
	if cursor_pos[0] > max_cursor_coordinate:
		cursor_pos[0] = max_cursor_coordinate
	if cursor_pos[1] > max_cursor_coordinate:
		cursor_pos[1] = max_cursor_coordinate

func _move(move_dir):
	if selected:
		ignore_input = true
		if $BlockGrid.push_block(cursor_pos, move_dir):
			move_cursor(move_dir)
			$SelectionGrid.clear()
	else:
		move_cursor(move_dir)
		$SelectionGrid.update_tile(cursor_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not ignore_input:
		if(Input.is_action_just_pressed("move_up")):
			_move(BlockLogicAuto.MoveDirection.NORTH)
		elif(Input.is_action_just_pressed("move_down")):
			_move(BlockLogicAuto.MoveDirection.SOUTH)
		elif(Input.is_action_just_pressed("move_left")):
			_move(BlockLogicAuto.MoveDirection.WEST)
		elif(Input.is_action_just_pressed("move_right")):
			_move(BlockLogicAuto.MoveDirection.EAST)
		elif(Input.is_action_just_pressed("select_block")):
			if selected:
				end_selection()
			else:
				if ($BlockGrid.get_block_at_cursor(cursor_pos)):
					start_selection()
#		elif(Input.is_action_just_pressed("delete_block")):
#			if($BlockGrid.get_block_at_cursor(cursor_pos)):
#				$BlockGrid.delete_block(cursor_pos)

func spawn_boat():
	var boat_dir = $BlockGrid/LandGrids.get_random_empty_dir()
	if boat_dir != null:
		var boat_grid = $BlockGrid/LandGrids.boat_grids[boat_dir]
		boat_grid.set_filled(true)
		var top_left_cell = boat_grid.top_left_cell_pos
		var incoming_boat_cargo = BoatOrder.new(boat_dir, top_left_cell)
		var outgoing_boat_order = BoatOrder.new(boat_dir, top_left_cell, $BlockGrid)
		var new_boat = boat_scenes[boat_dir].instance()
		new_boat.initialize(incoming_boat_cargo, outgoing_boat_order, top_left_cell)
		new_boat.connect("docking_finished", self, "handle_docking_finished")
		new_boat.position += top_left_cell * 64 + Vector2(64, 64)
		$BlockGrid.connect("state_updated", new_boat, "handle_state_update")
		self.add_child(new_boat)
		boat_grid.current_order = outgoing_boat_order
		boat_grid.current_boat = new_boat
	#	print("spawning boat: " + boat_dir)

func start_selection():
	selected = true
	highlight_block()
	$SelectionGrid.modulate = Color(0.1, 0.2, 0.9, 1.0)

func end_selection():
	selected = false
	ignore_input = false
	$SelectionGrid.update_tile(cursor_pos)
	$SelectionGrid.modulate = Color(1.0, 1.0, 1.0, 1.0)
	$SelectionGrid.show()

func highlight_block():
	$SelectionGrid.clear()
	var found_block = $BlockGrid.get_block_at_cursor(cursor_pos)
	$SelectionGrid.add_block(found_block)

func _on_BlockGrid_push_ended():
	ignore_input = false
	if not keep_blocks_selected:
		end_selection()

func handle_docking_finished(docking_data: Dictionary):
	$BlockGrid.queue_new_blocks(docking_data.blocks)
	match(docking_data.direction):
		"north":
			$BlockGrid/LandGrids/BoatNorthGrid.set_active(true)
		"east":
			$BlockGrid/LandGrids/BoatEastGrid.set_active(true)
		"west":
			$BlockGrid/LandGrids/BoatWestGrid.set_active(true)
		"south":
			$BlockGrid/LandGrids/BoatSouthGrid.set_active(true)

func _on_LandGrids_order_fulfilled(direction_idx):
	var direction_strings = ["east", "north", "west", "south"]
	match(direction_strings[direction_idx]):
		"north":
			$BlockGrid/LandGrids/BoatNorthGrid.set_active(false)
			$BlockGrid/LandGrids/BoatNorthGrid.set_filled(false)
		"east":
			$BlockGrid/LandGrids/BoatEastGrid.set_active(false)
			$BlockGrid/LandGrids/BoatEastGrid.set_filled(false)
		"west":
			$BlockGrid/LandGrids/BoatWestGrid.set_active(false)
			$BlockGrid/LandGrids/BoatWestGrid.set_filled(false)
		"south":
			$BlockGrid/LandGrids/BoatSouthGrid.set_active(false)
			$BlockGrid/LandGrids/BoatSouthGrid.set_filled(false)
	cursor_pos = Vector2(7, 7)
	end_selection()


func _on_BoatSpawner_spawn_boat() -> void:
	spawn_boat()
