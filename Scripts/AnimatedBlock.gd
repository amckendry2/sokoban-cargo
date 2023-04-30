extends Node2D

func initialize(block_texture: Texture, grid_coord: Vector2):
	$Sprite.texture = block_texture
	position = (grid_coord * 64) + Vector2(32, 32)

