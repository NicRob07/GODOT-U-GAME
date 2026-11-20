class_name State_Machine extends Node

var is_locked: bool = false

##nodo que vamos a controlar
@export var ControlledNode:Node

##estado por defecto
@export var DefaultState:State_Base

## estado en ejecucion en cada momento
var CurrentState:State_Base = null

func _ready():
	call_deferred("_state_default_start")

func _state_default_start():
	CurrentState = DefaultState
	_state_start()

## funcion que prepara las variables para el nuevo estado y lanza su start
func _state_start():
	prints("StateMachine", ControlledNode.name, "start state", CurrentState.name)
	## configuramos el estado
	CurrentState.ControlledNode = ControlledNode
	CurrentState.StateMachine = self
	CurrentState.start()
	
func change_to(new_state:String):
	if is_locked:
		return
		
	elif CurrentState and CurrentState.has_method("end"): CurrentState.end()
	CurrentState = get_node(new_state)
	_state_start()
	
#region metodos que se ejecutan solos

func _process(delta: float) -> void:
	if CurrentState and CurrentState.has_method("on_process"):
		CurrentState.on_process(delta)

func _physics_process(delta: float) -> void:
	if CurrentState and CurrentState.has_method("on_physics_process"):
		CurrentState.on_physics_process(delta)

func _input(event: InputEvent) -> void:
	if CurrentState and CurrentState.has_method("on_input"):
		CurrentState.on_input(event)

func _unhandled_input(event: InputEvent) -> void:
	if CurrentState and CurrentState.has_method("on_unhandled_input"):
		CurrentState.on_unhandled_input(event)

func _unhandled_key_input(event: InputEvent):
	if CurrentState and CurrentState.has_method("on_unhandled_key_input"):
		CurrentState.on_unhandled_key_input(event)
#endregion
