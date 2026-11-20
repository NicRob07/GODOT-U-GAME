extends CharacterBody2D

@export_group("Velocidad")
@export_range(0.1, 1.0) var walk_speed_factor: float = 0.5
@export_range(0.1, 1.0) var run_speed_factor: float = 0.85
@export var fallback_speed: float = 120.0

@export_group("Visión")
@export var vision_range: float = 180.0
@export_range(10.0, 180.0) var vision_angle: float = 70.0
@export_flags_2d_physics var wall_mask: int = 1
@export var lose_sight_time: float = 2.5
@export var start_facing_degrees: float = 90.0

@export_group("Comportamiento")
@export var patrol_path: Path2D
@export var patrol_wait_time: float = 1.0
@export var search_time: float = 4.0
@export var investigate_timeout: float = 6.0
@export var arrive_distance: float = 12.0

# Datos compartidos que leen los estados
var walk_speed: float = 0.0
var run_speed: float = 0.0

var patrol_points: PackedVector2Array = PackedVector2Array()
var patrol_index: int = 0

var facing: Vector2 = Vector2.DOWN
var look_offset: float = 0.0

var player_visible: bool = false
var last_seen_position: Vector2 = Vector2.ZERO
var time_since_seen: float = 0.0

var heard_noise: bool = false
var investigate_position: Vector2 = Vector2.ZERO

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var pivot: Node2D = $Pivot
@onready var cone_visual: Polygon2D = $Pivot/ConeVisual
@onready var vision_area: Area2D = $Pivot/VisionArea
@onready var cone_shape: CollisionPolygon2D = $Pivot/VisionArea/CollisionPolygon2D


func _ready() -> void:
	facing = Vector2.RIGHT.rotated(deg_to_rad(start_facing_degrees))
	nav_agent.target_desired_distance = arrive_distance
	_build_cone()
	_setup_speeds()
	_collect_patrol_points()
	NoiseBus.noise_made.connect(_on_noise_made)


func _physics_process(delta: float) -> void:
	_update_vision(delta)
	pivot.rotation = facing.angle() + look_offset


# ---------- Movimiento (lo usan los estados) ----------

func move_to(target: Vector2, speed: float) -> void:
	if is_at(target):
		stop()
		return

	var next_point: Vector2 = target
	if _has_navigation():
		if nav_agent.target_position != target:
			nav_agent.target_position = target
		next_point = nav_agent.get_next_path_position()

	var dir: Vector2 = global_position.direction_to(next_point)
	if dir != Vector2.ZERO:
		facing = dir
	velocity = dir * speed
	move_and_slide()


func stop() -> void:
	velocity = Vector2.ZERO


func is_at(target: Vector2) -> bool:
	return global_position.distance_to(target) <= arrive_distance


# Si el nivel no tiene región de navegación, va en línea recta
func _has_navigation() -> bool:
	return not NavigationServer2D.map_get_regions(nav_agent.get_navigation_map()).is_empty()


# ---------- Visión ----------

func _update_vision(delta: float) -> void:
	player_visible = false
	for body in vision_area.get_overlapping_bodies():
		if body.is_in_group("Player") and _has_line_of_sight(body):
			player_visible = true
			last_seen_position = body.global_position
			break

	if player_visible:
		time_since_seen = 0.0
	else:
		time_since_seen += delta


func _has_line_of_sight(target: Node2D) -> bool:
	var query := PhysicsRayQueryParameters2D.create(global_position, target.global_position, wall_mask)
	query.exclude = [get_rid()]
	var hit: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or hit["collider"] == target


func _build_cone() -> void:
	var points := PackedVector2Array([Vector2.ZERO])
	var half_angle := deg_to_rad(vision_angle) / 2.0
	var steps := 12

	for i in range(steps + 1):
		var a := -half_angle + (half_angle * 2.0) * (float(i) / steps)
		points.append(Vector2.RIGHT.rotated(a) * vision_range)

	cone_visual.polygon = points
	cone_shape.polygon = points
	cone_visual.color = Color(1, 1, 0, 0.25)


# ---------- Oído ----------

func _on_noise_made(pos: Vector2, radius: float) -> void:
	if global_position.distance_to(pos) <= radius:
		investigate_position = pos
		heard_noise = true


# ---------- Preparación ----------

func _setup_speeds() -> void:
	var base: float = fallback_speed
	var player := get_tree().get_first_node_in_group("Player")
	if player:
		var stats = player.get("MovementStats")
		if stats:
			base = float(stats.BaseSpeed)
	walk_speed = base * walk_speed_factor
	run_speed = base * run_speed_factor


func _collect_patrol_points() -> void:
	if patrol_path == null or patrol_path.curve == null:
		return
	for i in range(patrol_path.curve.point_count):
		patrol_points.append(patrol_path.to_global(patrol_path.curve.get_point_position(i)))
