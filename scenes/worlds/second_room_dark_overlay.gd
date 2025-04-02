extends PointLight2D
@export var keyid: float = 0.0
func _ready() -> void:
	self.show()

func _process(delta: float) -> void:

	if Global.KeyID == self.keyid:
		self.hide()
