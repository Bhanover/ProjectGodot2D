extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("RotateSaw")




func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
		body._loseLife()
		pass




 
