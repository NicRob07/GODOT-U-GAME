extends State_Base

var _time: float = 0.0


func on_physics_process(delta):
	_time += delta
	ControlledNode.move_to(ControlledNode.investigate_position, ControlledNode.run_speed)

	# Si oye otro ruido, el destino ya se actualizó: reinicia el tiempo
	if ControlledNode.heard_noise:
		ControlledNode.heard_noise = false
		_time = 0.0

	##Inicia bloque cambio de estado
	if ControlledNode.player_visible:
		_time = 0.0
		StateMachine.change_to(EnemyStatesNames.Chase)
	elif ControlledNode.is_at(ControlledNode.investigate_position) or _time >= ControlledNode.investigate_timeout:
		_time = 0.0
		StateMachine.change_to(EnemyStatesNames.Search)
