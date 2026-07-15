class_name LevelBlock
extends StaticBody2D

var level_rect := Rect2(0, 0, 1, 1)

@onready var sprite: ColorRect = %ColorRect
@onready var collision_shape: CollisionShape2D = %CollisionShape


func set_level_rect(level_x: int, level_y: int, level_width: int, level_height: int):
	level_rect = Rect2(level_x, level_y, level_width, level_height)
	if is_node_ready():
		_update()
	return self


func _ready() -> void:
	_update()


func _update() -> void:
	global_position = level_rect.position * Constants.LEVEL_CELL_SIZE
	sprite.size = level_rect.size * Constants.LEVEL_CELL_SIZE

	var collision_rect: = RectangleShape2D.new()
	collision_rect.size = sprite.size

	collision_shape.shape = collision_rect
	collision_shape.position = sprite.get_rect().get_center()
