extends State_Base


func on_physics_process(delta):
	ControlledNode.set_alert(false)

	##Inicia bloque cambio de estado
	if ControlledNode.is_player_in_view():
		StateMachine.change_to(CameraStatesNames.Alert)
