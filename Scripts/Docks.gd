extends Node2D

const animated_block_scene = preload("res://Scenes/AnimatedBlock.tscn")
const BlockLogic = preload("res://Scripts/BlockLogic.gd")

var selected: bool = false

var cursor_pos: Vector2 = Vector2(3, 3)

func _ready():
	$SelectionGrid.update_tile(cursor_pos)
	$BlockGrid.initialize_state()
	
func move_up():
	cursor_pos += Vector2.UP
	$SelectionGrid.update_tile(cursor_pos)
	
func move_down():
	cursor_pos += Vector2.DOWN
	$SelectionGrid.update_tile(cursor_pos)

func move_left():
	cursor_pos += Vector2.LEFT
	$SelectionGrid.update_tile(cursor_pos)
	
func move_right():
	cursor_pos += Vector2.RIGHT
	$SelectionGrid.update_tile(cursor_pos)

func block_is_selected(block):
	return block.pos == cursor_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_just_pressed("move_up")):
		if selected:
			$BlockGrid.push_block(cursor_pos, BlockLogic.MoveDirection.NORTH)
		else: 
			move_up()
	elif(Input.is_action_just_pressed("move_down")):
		if selected:
			$BlockGrid.push_block(cursor_pos, BlockLogic.MoveDirection.SOUTH)
		else:
			move_down()
	elif(Input.is_action_just_pressed("move_left")):
		if selected:
			$BlockGrid.push_block(cursor_pos, BlockLogic.MoveDirection.WEST)
		else:
			move_left()
	elif(Input.is_action_just_pressed("move_right")):
		if selected:
			$BlockGrid.push_block(cursor_pos, BlockLogic.MoveDirection.EAST)
		else:
			move_right()
	elif(Input.is_action_just_pressed("select_block")):
		if selected:
			selected = false
		else:
			if ($BlockGrid.get_block_at_cursor(cursor_pos)):
				start_selection()

func start_selection():
	selected = true
	$SelectionGrid.hide()

func end_selection():
	selected = false
	$SelectionGrid.show()

func _on_BlockGrid_push_ended():
	end_selection()
