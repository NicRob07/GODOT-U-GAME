class_name Stone
extends CharacterBody2D

@export_group("Vuelo")
@export var throw_speed: float = 300.0
@export var brake_start_distance: float = 90.0
@export var brake_deceleration: float = 600.0
@export var stop_speed: float = 8.0

@export_group("Rebote")
@export_range(0.0, 1.0) var bounce_damping: float = 0.5

@export_group("Ruido")
@export var sound_radius: float = 250.0

var _traveled: float = 0.0
var _noise_made: bool = false


func launch(from: Vector2, dir: Vector2) -> void:
	global_position = from
	velocity = dir.normalized() * throw_speed


func _physics_process(delta: float) -> void:
	# Pasado el rango de vuelo, empieza a frenarse
	if _traveled >= brake_start_distance:
		velocity = velocity.move_toward(Vector2.ZERO, brake_deceleration * delta)

	var motion: Vector2 = velocity * delta
	var collision := move_and_collide(motion)

	if collision:
		# Rebota, frena de inmediato y hace ruido
		_traveled = brake_start_distance
		velocity = velocity.bounce(collision.get_normal()) * bounce_damping
		_make_noise()
	else:
		_traveled += motion.length()

	if velocity.length() <= stop_speed:
		_land()


func _land() -> void:
	velocity = Vector2.ZERO
	set_physics_process(false)
	_make_noise()


func _make_noise() -> void:
	if _noise_made:
		return
	_noise_made = true
	NoiseBus.emit_noise(global_position, sound_radius)
	# Aquí luego: sonido, partículas, etc.
