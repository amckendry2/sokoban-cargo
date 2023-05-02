extends Node2D

export var intro_title_pos: Vector2
export var ingame_title_pos: Vector2
export var intro_cam_pos: Vector2
var _title_start_size = Vector2(2,2)

var score: int = 0

var _paused: bool = false
var _intro_t: float = 0

func _ready() -> void:
	$BoatUI/BoatCount.text = str(score)
	if Intro.state == Intro.State.START:
		get_tree().paused = true
		$TimeUI.visible = false
		$BoatUI.visible = false
		$IntroText.visible = true
		$LogoNew.position = intro_title_pos
		$LogoNew.scale = _title_start_size
		get_parent().position = intro_cam_pos

func _intro_proc(delta: float) -> void:
	match Intro.state:
		Intro.State.START:
			if Input.is_action_just_pressed("select_block"):
				Intro.state = Intro.State.MOVING
				$IntroText.visible = false

		Intro.State.MOVING:
			var smooth_t = smoothstep(0, 1, _intro_t)
			var cam = get_parent()
			$LogoNew.position = lerp(intro_title_pos, ingame_title_pos, smooth_t)
			$LogoNew.scale = lerp(_title_start_size, Vector2(1,1), smooth_t)
			cam.position = lerp(intro_cam_pos, Vector2(0,0), smooth_t)
			if _intro_t >= 1:
				Intro.state = Intro.State.END
				$BoatUI.visible = true
				$TimeUI.visible = true
				get_tree().paused = false
			_intro_t += 0.01
	pass

func _vec2_smoothstep(from: Vector2, to: Vector2, t: float) -> Vector2:
	return Vector2(smoothstep(from.x, to.x, t), smoothstep(from.y, to.y, t))

func _process(delta: float) -> void:
	if Intro.state != Intro.State.END:
		_intro_proc(delta)
		return

	var t = time_left()
	$TimeUI/TimeLeft.text = str(t / 60) + (":%02d" % (t % 60))

func time_left() -> int: # in seconds
	return int($TimeUI/Timer.time_left)

func increment_score():
	score += 1
	$BoatUI/BoatCount.text = str(score)

func game_over():
	get_tree().paused = true
	_paused = true
	$PauseUI.visible = true
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		game_over()
	elif event.is_action_pressed("Restart") and _paused:
		get_tree().reload_current_scene()
		get_tree().paused = false


func _on_Timer_timeout() -> void:
	game_over()

func _on_LandGrids_order_fulfilled(_dir) -> void:
	increment_score()
