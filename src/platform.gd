@tool
class_name Platform
extends StaticBody2D

@export var body: MeshInstance2D
@export var hitbox: CollisionShape2D

@export var size_in_cells := Vector2i(30, 1):
	set(value):
		size_in_cells = value
		if is_node_ready():
			_update_size()


func _ready() -> void:
	_update_size()


func _update_size() -> void:
	var mesh := QuadMesh.new()
	mesh.size = size_in_cells * GameConfig.CELL_SIZE
	body.mesh = mesh

	var shape := RectangleShape2D.new()
	shape.size = mesh.size
	hitbox.shape = shape
