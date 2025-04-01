extends CharacterBody2D

@export var keyid: float = 0.0
func _ready():
	$CollisionShape2D.disabled = false
	$Sprite2D.visible = true
func _process(delta):

	if self.keyid in Global.Collected_Keys:
		$CollisionShape2D.disabled = true
		print("Door on level 3_1 disabled!")
		$Sprite2D.visible = false
	#else:
		#$CollisionShape2D.disabled = false
		#$Sprite2D.visible = $Sprite2D.visible
