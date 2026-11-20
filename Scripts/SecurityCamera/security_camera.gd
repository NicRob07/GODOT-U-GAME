@tool
class_name SecurityCamera
extends Node2D

@export var vision_range: float = 200.0:
	set(value):
		vision_range = value
		_build_cone()

@export_range(10.0, 180.0) var vision_angle: float = 60.0:
	set(value):
		vision_angle = value
		_build_cone()

@export var color_idle: Color = Color(1, 1, 1, 0.35)
@export var color_alert: Color = Color(1, 0, 0, 0.45)

@export_group("Alerta")
@export var alert_radius: float = 250.0
@export var alert_cooldown: float = 3.0

var _last_alert_time: float = -999.0

@onready var cone_visual: Polygon2D = $ConeVisual
@onready var vision_area: Area2D = $VisionArea
@onready var cone_shape: CollisionPolygon2D = $VisionArea/CollisionPolygon2D


func _ready() -> void:
	_build_cone()
	set_alert(false)


func _build_cone() -> void:
	if not is_node_ready():
		return

	var points := PackedVector2Array([Vector2.ZERO])
	var half_angle := deg_to_rad(vision_angle) / 2.0
	var steps := 12

	for i in range(steps + 1):
		var a := -half_angle + (half_angle * 2.0) * (float(i) / steps)
		points.append(Vector2.RIGHT.rotated(a) * vision_range)

	cone_visual.polygon = points
	cone_shape.polygon = points


func set_alert(active: bool) -> void:
	cone_visual.color = color_alert if active else color_idle


func is_player_in_view() -> bool:
	for body in vision_area.get_overlapping_bodies():
		if body.is_in_group("Player"):
			return true
	return false


func raise_alert() -> void:
	var now: float = Time.get_ticks_msec() / 1000.0
	if now - _last_alert_time < alert_cooldown:
		return
	_last_alert_time = now
	NoiseBus.emit_noise(global_position, alert_radius)
