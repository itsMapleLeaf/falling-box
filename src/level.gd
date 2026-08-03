class_name Level

var rects: Array[Rect2i] = []
var _bounds := Rect2i(0, 0, 0, 0)

var bounds: Rect2i:
	get:
		return _bounds


func with_rects(new_rects: Array[Rect2i]) -> Level:
	self.rects = new_rects
	for rect in rects:
		_bounds = _bounds.merge(rect)
	return self
