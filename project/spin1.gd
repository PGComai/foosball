extends RigidBody


var g = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	linear_velocity -= Vector3.DOWN * g * delta
