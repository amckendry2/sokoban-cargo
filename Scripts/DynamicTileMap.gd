extends TileMap

func _ready():
	pass # Replace with function body.

func add_tile(pos: Vector2, sprite_idx: int):
	set_cellv(pos, sprite_idx)

func clear_tile(pos: Vector2):
	set_cellv(pos, -1)

func add_blocks(blocks: Dictionary):
	for block in blocks:
		add_block(block)

func clear_blocks(blocks: Dictionary):
	for block in blocks:
		clear_block(block)

func add_block(block: Dictionary):
	for cell in block["cells"]:
		set_cellv(cell, 0)

func clear_block(block: Dictionary):
	for cell in block["cells"]:
		set_cellv(cell, -1)
