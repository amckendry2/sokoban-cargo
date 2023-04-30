extends DynamicTileMap

func _ready():
	$AnimationPlayer.play("Glow")

func update_tile(new_pos: Vector2):
	clear()
	add_tile(new_pos, 0)
