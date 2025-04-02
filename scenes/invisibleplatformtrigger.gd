extends Node2D

@onready var piston = Global.piston



func _ready():
	$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	else:
		piston.go()
