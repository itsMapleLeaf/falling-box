class_name FallingBoxSpawner
extends Node

signal box_spawned(box: FallingBox)

const FALLING_BOX = preload("uid://b6hwok27qogib")

@export var level: Level

@onready var spawn_timer: Timer = $Timer
@onready var falling_box_layer: Node2D = $"../FallingBoxLayer"

var spawn_rng := RandomNumberGenerator.new()


func _ready() -> void:
	spawn_rng.randomize()
	spawn_timer.timeout.connect(spawn_box)


func spawn_box() -> FallingBox:
	var box: FallingBox = FALLING_BOX.instantiate()
	falling_box_layer.add_child(box)
	box.global_position = level.get_random_box_spawn_position()
	box.reset_physics_interpolation()
	box_spawned.emit(box)
	return box
