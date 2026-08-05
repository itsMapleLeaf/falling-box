class_name Level

const CELL_SIZE = 50.0

var rects: Array[Rect2i] = []
var _bounds := Rect2i(0, 0, 0, 0)

var bounds: Rect2i:
	get:
		return _bounds

var world_bounds: Rect2:
	get:
		return Rect2(bounds.position * CELL_SIZE, bounds.size * CELL_SIZE)


func with_rects(new_rects: Array[Rect2i]) -> Level:
	self.rects = new_rects
	_bounds = Rect2i()
	for rect in rects:
		_bounds = _bounds.merge(rect)
	return self


func create_level_blocks() -> Array[LevelBlock]:
	var blocks: Array[LevelBlock] = []
	for level_rect in rects:
		var block: LevelBlock = load("uid://dtvqbjemca8sx").instantiate()
		block.set_level_rect(level_rect)
		blocks.append(block)
	return blocks


func get_spawn_x_position() -> float:
	return randf_range(bounds.position.x, bounds.end.x) * CELL_SIZE
