extends State_Base


func on_physics_process(delta):
	ControlledNode.set_alert(true)
	ControlledNode.raise_alert()

	##Inicia bloque cambio de estado
	if not ControlledNode.is_player_in_view():
		StateMachine.change_to(CameraStatesNames.Idle)
