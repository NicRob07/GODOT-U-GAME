extends State_Base


func on_physics_process(delta):
	
	##Inicia Bloque cambiar de estado
	if Input.get_vector("Left", "Rigth","Up","Down"):
		StateMachine.change_to(PlayerStatesNames.Walk)
	 
