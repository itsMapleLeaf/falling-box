extends Node

const LEVEL_CELL_SIZE = 50

var default_level := Level.new().with_rects(
	[Rect2i(0, 0, 24, 1), Rect2i(0, 1, 22, 1), Rect2i(0, 2, 20, 1)]
)
