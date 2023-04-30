class_name DynamicTileMap extends TileMap

export var tile_index: int = 1

func add_tile(pos: Vector2, sprite_idx: int):
	set_cellv(pos, sprite_idx)
#	update_bitmask_area(pos) # TODO: Figure out if this is necessary here...

func clear_tile(pos: Vector2):
	set_cellv(pos, -1)
#	update_bitmask_area(pos)

func add_blocks(blocks: Dictionary):
	for block in blocks:
		add_block(block)

func clear_blocks(blocks: Dictionary):
	for block in blocks:
		clear_block(block)

func add_block(block: Dictionary):
	for cell in block["cells"]:
		set_cellv(cell, tile_index)
		update_bitmask_area(cell)


func clear_block(block: Dictionary):
	for cell in block["cells"]:
		set_cellv(cell, -1)
		update_bitmask_area(cell)
