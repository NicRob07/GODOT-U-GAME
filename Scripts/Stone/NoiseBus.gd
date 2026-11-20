extends Node

signal noise_made(position: Vector2, radius: float)


func emit_noise(position: Vector2, radius: float) -> void:
	print("Ruido en ", position, " | radio: ", radius)  # quítalo cuando ya funcione
	noise_made.emit(position, radius)
