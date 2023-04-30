extends TileMap

var _active: bool = true

func set_active(active):
	_active = active
	
func is_active():
	return _active
