extends DynamicTileMap

func _ready():
	pass
	# Turn off animation because its overwriting the selection modulation
	# $AnimationPlayer.play("Glow")

func update_tile(new_pos: Vector2):
	clear()
	add_tile(new_pos, tile_index)
	update_bitmask_area(new_pos)
