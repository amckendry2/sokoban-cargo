extends Node2D

signal move_finished

const animated_block_scene = preload("res://Scenes/AnimatedBlock.tscn")

var animation_name: String

const block_textures = [
    preload("res://Assets/icon.png")
]

func _ready():
    $AnimationPlayer.play(animation_name)

func initialize(_animation_name: String):
    animation_name = _animation_name
    
func add_block(grid_coord: Vector2, texture_idx: int):
    var block = animated_block_scene.instance()
    block.initialize(block_textures[texture_idx], grid_coord)
    $Blocks.add_child(block)

func _on_AnimationPlayer_animation_finished(anim_name):
    queue_free()
