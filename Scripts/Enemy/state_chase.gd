extends State_Base


func on_physics_process(delta):
	# Mientras persigue, ignora los ruidos
	ControlledNode.heard_noise = false
	ControlledNode.move_to(ControlledNode.last_seen_position, ControlledNode.run_speed)

	##Inicia bloque cambio de estado
	var lost: bool = ControlledNode.time_since_seen >= ControlledNode.lose_sight_time
	var reached_last_seen: bool = not ControlledNode.player_visible and ControlledNode.is_at(ControlledNode.last_seen_position)

	if lost or reached_last_seen:
		ControlledNode.investigate_position = ControlledNode.last_seen_position
		StateMachine.change_to(EnemyStatesNames.Investigate)
