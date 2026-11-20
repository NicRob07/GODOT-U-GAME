extends State_Base

var direction: Vector2
var BaseSpeed: float

func _ready() -> void:
	BaseSpeed = ControlledNode.MovementStats.BaseSpeed

func WalkControl(delta):
	direction = Input.get_vector("Left", "Rigth", "Up", "Down")
	if direction:
		ControlledNode.velocity = direction * BaseSpeed
	else:
		ControlledNode.velocity = ControlledNode.velocity.move_toward(Vector2.ZERO, BaseSpeed)
	
	return direction


func on_physics_process(delta):
	WalkControl(delta)
	ControlledNode.move_and_slide()
	
	##Inicia bloque cambio de estado
	
	if direction == Vector2.ZERO:
		StateMachine.change_to(PlayerStatesNames.Idle)
	
