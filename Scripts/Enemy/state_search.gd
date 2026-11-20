extends State_Base

var _time: float = 0.0


func on_physics_process(delta):
	_time += delta
	ControlledNode.stop()
	# Mira de lado a lado
	ControlledNode.look_offset = sin(_time * 2.5) * deg_to_rad(70.0)

	##Inicia bloque cambio de estado
	if ControlledNode.player_visible:
		_reset()
		StateMachine.change_to(EnemyStatesNames.Chase)
	elif ControlledNode.heard_noise:
		ControlledNode.heard_noise = false
		_reset()
		StateMachine.change_to(EnemyStatesNames.Investigate)
	elif _time >= ControlledNode.search_time:
		_reset()
		StateMachine.change_to(EnemyStatesNames.Patrol)


func _reset() -> void:
	_time = 0.0
	ControlledNode.look_offset = 0.0
