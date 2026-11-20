extends State_Base

var _wait_left: float = 0.0


func on_physics_process(delta):
	if _wait_left > 0.0:
		_wait_left -= delta
		ControlledNode.stop()
	elif ControlledNode.patrol_points.is_empty():
		ControlledNode.stop()
	else:
		var target: Vector2 = ControlledNode.patrol_points[ControlledNode.patrol_index]
		ControlledNode.move_to(target, ControlledNode.walk_speed)
		if ControlledNode.is_at(target):
			ControlledNode.patrol_index = (ControlledNode.patrol_index + 1) % ControlledNode.patrol_points.size()
			_wait_left = ControlledNode.patrol_wait_time

	##Inicia bloque cambio de estado
	if ControlledNode.player_visible:
		StateMachine.change_to(EnemyStatesNames.Chase)
	elif ControlledNode.heard_noise:
		ControlledNode.heard_noise = false
		StateMachine.change_to(EnemyStatesNames.Investigate)
