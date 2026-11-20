class_name StoneThrower
extends Node

@export var stone_scene: PackedScene
@export var cooldown: float = 0.5

var _can_throw: bool = true
var _facing: Vector2 = Vector2.DOWN


func _physics_process(_delta: float) -> void:
	# Guarda la última dirección en la que se movió el jugador
	var input_dir: Vector2 = Input.get_vector("Left", "Rigth", "Up", "Down")
	if input_dir != Vector2.ZERO:
		_facing = input_dir.normalized()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Throw") and _can_throw:
		_throw()


func _throw() -> void:
	var player := get_parent() as Node2D

	var stone := stone_scene.instantiate() as Stone
	get_tree().current_scene.add_child(stone)
	stone.launch(player.global_position, _facing)

	_can_throw = false
	await get_tree().create_timer(cooldown).timeout
	_can_throw = true
