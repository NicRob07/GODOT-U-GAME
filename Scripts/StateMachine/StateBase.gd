class_name State_Base extends Node

##Referencia al nodo que vamos a utilizar
@onready var ControlledNode:Node = owner

## Todos los estados deben poder hablar con la maquina de estados por ende se hace referencia
var StateMachine:State_Machine

#region metodos comunes

##metodo que se ejecuta al entrar en el estado
func start():
	pass

func end():
	pass

#endregion
